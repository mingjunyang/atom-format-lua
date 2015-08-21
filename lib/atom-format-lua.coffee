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

        wkspc=path.resolve('./luacode')

        formatterScript=path.join(wkspc,'formatter.lua')
        lua51 = atom.config.get "atom-format-lua.lua51"

        lua51path=process.spawnSync('which', ['lua5.1'])
        params = [formatterScript, "--file",tempfile]

        if lua51path.stderr
            console.log 'no lua5.1'
        if lua51path.stdout
            lua51 = lua51path.stdout.asciiSlice().replace(/\s*$/,'')

        which = process.spawnSync('which', ['lua5.1']).status
        if which == 1 and not fs.existsSync(lua51)
            console.log "unable to open lua5.1"
            return

        proc = process.spawn( lua51, params,{cwd:wkspc})
        proc.stdout.on('data',(data)-> console.log 'out' ,data.asciiSlice())
        proc.stderr.on('data',(data)-> console.log 'err' ,data.asciiSlice())
