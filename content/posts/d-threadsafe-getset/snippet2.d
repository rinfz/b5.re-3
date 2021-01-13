mixin template StateProperty(T, string Name)
{
    mixin(`private ` ~ T.stringof ~ ` _` ~ Name ~ `;
        @property ` ~ T.stringof ~ ` ` ~ Name ~ `() nothrow
        {
            synchronized
            {
                return _` ~ Name ~ `;
            }
        }

        @property void ` ~ Name ~ `(` ~ T.stringof ~ ` prop) nothrow
        {
            synchronized
            {
                _` ~ Name ~ ` = prop;
            }
        }`
    );
}