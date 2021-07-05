type
  Request = object of RootObj
  Response = object of RootObj
  Other = object of RootObj

  Login[T: Request | Response] = object
    when T is Request:
      data: string
    else:
      statusCode: int

let request = Login[Request](data: "payload")
let response = Login[Response](statusCode: 200)

# error!
# let other = Login[Other](statusCode: 500)

proc execute[T: Request](request: Login[T]) =
  echo request

request.execute()
response.execute()
