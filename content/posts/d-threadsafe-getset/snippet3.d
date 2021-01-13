private string _serverName;

@property string serverName() nothrow
{
    synchronized
    {
        return _serverName;
    }
}

@property void serverName(string prop) nothrow
{
    synchronized
    {
        _serverName = prop;
    }
}