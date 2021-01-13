struct State
{
    mixin StateProperty!(string, "serverName");
    mixin StateProperty!(string, "accessToken");
    // ...
}