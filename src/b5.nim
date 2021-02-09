import strscans
import os
import htmlgen
import strutils
import sequtils
import parsecsv
import algorithm
import times
import xmltree as xt

import markdown

type
  Header = object
    title: string
    date: string

  Post = object
    header: Header
    filename, body: string
    draft: bool

let htmlTemplate = readFile("template.html")

func displayBody(post: Post): string = article(h2(post.header.title), p(post.header.date), markdown(post.body))
func htmlFilename(post: Post): string = post.filename & ".html"
proc realDate(post: Post): DateTime = post.header.date.parse("yyyy-MM-dd")

proc parseSnippet(path, name: string): string =
  # see for language names
  # https://github.com/highlightjs/highlight.js/blob/master/SUPPORTED_LANGUAGES.md
  let language = case name.split(".")[^1]
    #  ext   language
    of "py": "python"
    of "rs": "rust"
    of "asm": "x86asm"
    of "d": "d"
    of "cpp": "cpp"
    of "nim": "nim"
    else: "unknown"

  let content = xt.escape(readFile(joinPath(path, "snippet" & name)))
  if language == "unknown":
    result = pre(code(class="plaintext", style="background:var(--codebg)", content))
  else:
    result = pre(code(class=language, style="background:var(--codebg)", content))

proc processPost(path: string): Post =
  result.filename = lastPathPart(path)
  result.draft = false
  for line in lines(joinPath(path, "post.md")):
    var tag, tagBody: string
    if line.scanf("@$w $*", tag, tagBody):
      case tag:
        of "title":
          result.header.title = tagBody
        of "date":
          result.header.date = tagBody
        of "snippet":
          result.body &= parseSnippet(path, tagBody)
        of "draft":
          result.draft = true
        else:
          doAssert(false, "unknown tag: " & tag)
    else:
      result.body &= line & '\n'

proc render(title, body: string; isIndex: bool = false): string =
  let nav = ul(
    li(a(href="/", "Home")),
    li(a(href="https://github.com/rinfz", "Github")),
    li(a(href="/atom.xml", "(rss feed)"))
  )

  result = htmlTemplate.replace("@title", title).replace("@body", body).replace("@nav", nav)
  if isIndex:
    result = result.replace("@hl", "")
  else:
    result = result.replace("@hl", """
      <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/10.5.0/styles/kimbie.dark.min.css">
      <script src="/js/highlight.pack.js"></script>
      <script>hljs.initHighlightingOnLoad();</script>
    """)
  result = result.replace("<code>", "<code class=\"plaintext\" style=\"background:var(--codebg)\">")

proc writePost(outDir: string; post: Post) =
  writeFile(joinPath(outDir, post.htmlFilename), render(post.header.title, post.displayBody))

proc getAndWritePosts(inDir, outDir: string): seq[Post] =
  createDir(outDir)

  for kind, path in walkDir(inDir):
    if kind == PathComponent.pcDir:
      let post = processPost(path)
      if not post.draft:
        result.add(post)
        writePost(outDir, post)

proc postListItem(post: Post): string =
  li(
    a(href="/posts/" & post.htmlFilename,
      post.header.title,
      br(),
      span(class="indexListDate", post.header.date),
    )
  )

proc sorted(posts: seq[Post]): seq[Post] = posts.sortedByIt(it.realDate).reversed

proc postList(posts: seq[Post]): string =
  ul(class="indexList"):
    join(posts.sorted.map(postListItem))

proc linkList: string =
  var parser: CsvParser
  defer: close(parser)
  parser.open(joinPath("content", "links.csv"))
  parser.readHeaderRow()
  while parser.readRow():
    result &= li(
      a(href=parser.rowEntry("link"),
        parser.rowEntry("title"),
        br(),
        span(class="indexListDate", parser.rowEntry("date")),
      )
    )
  result = ul(class="indexList links", result)


proc birdList: string =
  var p: CsvParser
  defer: close(p)
  p.open(joinPath("content", "birds.csv"))
  p.readHeaderRow()
  while p.readRow():
    result &= li(a(href=p.rowEntry("link"), p.rowEntry("name")))
  result = ul(id="birdList", result)

proc songList: string =
  var p: CsvParser
  defer: close(p)
  p.open(joinPath("content", "songs.csv"))
  p.readHeaderRow()
  while p.readRow():
    result &= li(a(href=p.rowEntry("link"),
      p.rowEntry("name"),
      br(),
      span(class="indexListDate", p.rowEntry("artist")),
    ))

  result = ul(class="indexList", result)

proc whiskyList: string =
  var p: CsvParser
  defer: close(p)
  p.open(joinPath("content", "whisky.csv"))
  p.readHeaderRow()
  while p.readRow():
    result &= `div`(class="whisky",
      details(
        summary(p.rowEntry("name")),
        ul(style="margin-top:0.5rem",
          li(strong("Nose") & " " & p.rowEntry("nose")),
          li(strong("Palate") & " " & p.rowEntry("palate")),
          li(strong("Finish") & " " & p.rowEntry("finish")),
          li(strong("Rating") & " " & p.rowEntry("rating")),
        ),
        p(style="margin-top:0.5rem", p.rowEntry("notes")),
      )
    )

proc writeIndex(outDir: string; posts: seq[Post]) =
  let
    column1 = `div`(
      h2(class="lh2", "Posts"),
      postList(posts),
      h2(class="lh2", style="margin-top:1rem", "Cool Songs"),
      songList(),
      h2(class="lh2", style="margin-top:1rem", "Whisky"),
      whiskyList(),
      h2(class="lh2", style="margin-top:1rem", "Bird Log"),
      birdList(),
    )
    column2 = `div`(
      h2(class="rh2", "Cool Links"),
      linkList(),
    )
  let body = `div`(class="main",
    column1,
    column2,
  )
  writeFile(joinPath(outDir, "index.html"), render("Barely Laughing", body, true))

proc rssEntry(post: Post): xt.XmlNode =
  var
    alternate = xt.newElement("link")
    title = xt.newElement("title")
    published = xt.newElement("published")
    updated = xt.newElement("updated")
    authTop = xt.newElement("author")
    authName = xt.newElement("name")
    authUri = xt.newElement("uri")
    content = xt.newElement("content")

  alternate.attrs = xt.toXmlAttributes({"type": "text/html", "rel": "alternate", "href": "https://b5.re/posts/" & post.htmlFilename()})
  title.add(xt.newText(post.header.title))
  published.add(xt.newText(post.header.date))
  updated.add(xt.newText(post.header.date))
  authName.add(xt.newText("Matthew Rawcliffe"))
  authUri.add(xt.newText("https://b5.re/"))
  authTop.add(authName)
  authTop.add(authUri)
  content.attrs = xt.toXmlAttributes({"type": "html"})
  content.add(xt.newText(markdown(post.body)))

  result = xt.newXmlTree("entry", [alternate, title, published, updated, authTop, content])

proc writeRss(posts: seq[Post]) =
  var
    title = xt.newElement("title")
    link = xt.newElement("link")
    self = xt.newElement("link")
    updated = xt.newElement("updated")
    authTop = xt.newElement("author")
    authName = xt.newElement("name")
  
  title.add(xt.newText("Barely Laughing"))
  link.attrs = xt.toXmlAttributes({"href": "https://b5.re/"})
  self.attrs = xt.toXmlAttributes({"type": "application/atom+xml", "rel": "self", "href": "https://b5.re/atom.xml"})
  updated.add(xt.newText($(now().utc)))
  authName.add(xt.newText("Matthew Rawcliffe"))
  authTop.add(authName)

  let top = xt.newXmlTree("feed", @[title, link, self, updated, authTop] & posts.sorted.map(rssEntry)[0..4])
  writeFile(joinPath("public", "atom.xml"), $top)

proc main =
  let
    inDir = joinPath("content", "posts")
    outDir = joinPath("public", "posts")

  let posts = getAndWritePosts(inDir, outDir)
  writeIndex("public", posts)
  writeRss(posts)

when isMainModule:
  main()