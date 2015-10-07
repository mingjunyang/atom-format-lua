{CompositeDisposable} = require 'atom'
process = require 'child_process'
path = require('path');

module.exports = AtomFormatLua =
    subscriptions: null

    activate: (state) ->

        @subscriptions = new CompositeDisposable

        @subscriptions.add atom.commands.add 'atom-workspace', 'atom-format-lua:format': => @format(state)

    deactivate: ->
        @subscriptions.dispose()


    format:(state) ->

        editor=atom.workspace.getActiveTextEditor()
        text=editor.getText()
        tempfile=''

        if editor.getGrammar().name=='Lua'
            tempfile=editor.getPath()
        else
            return

        wkspc=path.join(atom.packages.packageDirPaths[0],'atom-format-lua/luacode')

        console.log(wkspc)

        formatterScript=path.join(wkspc,'formatter.lua')

        lua51path=process.spawnSync('which', ['lua5.1'])
        params = [formatterScript, "--file",tempfile]

        # console.log lua51path

        try
            if lua51path.stderr.length
                console.log 'no lua5.1'
            if lua51path.stdout.length
                lua51 = lua51path.stdout.toString().replace(/\s*$/,'')
                # console.log(lua51path.stdout.toString())
        catch error
            # console.log error
            lua51 = atom.config.get "atom-format-lua.lua51"
            # console.log lua51

        # which = process.spawnSync('which', ['lua5.1']).status
        # if which == 1 and not fs.existsSync(lua51)
        #     console.log "unable to open lua5.1"
        #     return

        console.log(lua51,params)

        proc = process.spawn( lua51, params,{cwd:wkspc})

        # console.log proc
        #
        # proc.stdout.on('data',(data)-> console.log 'out' ,data.asciiSlice())
        # proc.stderr.on('data',(data)-> console.log 'err' ,data.asciiSlice())
