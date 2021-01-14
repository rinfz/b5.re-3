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

let
  htmlTemplate = readFile("template.html")
  githubLink = a(href="https://github.com/rinfz", "Github")
  homeLink = a(href="/", "Home")

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
        else:
          doAssert(false, "unknown tag: " & tag)
    else:
      result.body &= line & '\n'

proc render(title, body, nav: string; isIndex: bool = false): string =
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
  writeFile(joinPath(outDir, post.htmlFilename), render(post.header.title, post.displayBody, homeLink & " " & githubLink))

proc getAndWritePosts(inDir, outDir: string): seq[Post] =
  createDir(outDir)

  for kind, path in walkDir(inDir):
    if kind == PathComponent.pcDir:
      let post = processPost(path)
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

proc postList(posts: seq[Post]): string =
  ul(class="indexList"):
    join(posts.sortedByIt(it.realDate).reversed.map(postListItem))

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

proc writeIndex(outDir: string; posts: seq[Post]) =
  let
    column1 = `div`(
      h2(class="lh2", "Posts"),
      postList(posts),
      h2(class="lh2", style="margin-top:1rem", "Cool Songs"),
      songList(),
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
  writeFile(joinPath(outDir, "index.html"), render("Barely Laughing", body, githubLink, true))

proc main =
  let
    inDir = joinPath("content", "posts")
    outDir = joinPath("public", "posts")

  let posts = getAndWritePosts(inDir, outDir)
  writeIndex("public", posts)

when isMainModule:
  main()