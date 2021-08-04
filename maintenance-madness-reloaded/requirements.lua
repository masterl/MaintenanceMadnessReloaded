-- This is currently a dummy file just to keep track of dependencies
return {
    dev_dependencies = {
        { name = 'busted' },
        { name = 'luacov' },
        { name = 'luaformatter' },
        { name = 'luacheck' },
        {
            name = 'luacov-reporters',
            link = 'https://raw.githubusercontent.com/tarantool/luacov-reporters/master/luacov-reporters-scm-1.rockspec'
        }
    }
}
