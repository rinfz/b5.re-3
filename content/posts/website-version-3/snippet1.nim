proc parseSnippet = discard  # omitted for the purposes of the post

proc processPost(path: string): Post =
  # posts have their own dir and the text for each is always in post.md
  for line in lines(joinPath(path, "post.md")):
    var tag, tagBody: string
    if line.scanf("@$w $*", tag, tagBody):  # scan each line in the post looking for @<tag>
      case tag:
        of "title": # matches @title
          result.header.title = tagBody
        of "date": # similar
          result.header.date = tagBody
        of "snippet": # similar
          result.body &= parseSnippet(path, tagBody)
        else:
          doAssert(false, "unknown tag: " & tag)
    else:
      result.body &= line & '\n'