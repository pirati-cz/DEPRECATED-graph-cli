repl = require('repl')
Graph = require('graph-common').Graph

class CLI

  @running = false
  @message = ""
  @delimeter = ""
  @input_message = ">>"

  @run: (argv, exit) ->
    configuration_manager = 
    CLI.graph = new Graph(CLI.configuration_manager(argv), () ->
      console.log CLI.graph.configuration.name
      repl.start({
        prompt: "> ",
        input: process.stdin,
        output: process.stdout,
        useColors: true,
        useGlobal: true,
        ignoreUndefined: true,
        eval: (cmd, context, filename, callback) ->
          cmd = cmd.replace(/^\s*\(\s*/g, '').replace(/\s*\)\s*$/g, '')
          #console.log('query: "'+cmd+'"')
          if not cmd or cmd == ''
          	callback(null, undefined)
          	return null
          CLI.graph.run(cmd, (query) -> callback(null, query.result))
      }).on('exit', (args...) ->
        CLI.graph?.disconnect()
        exit(args...)
      )
    )

  @configuration_manager: (argv) ->
    mongo_host = argv.host || process.env.DB_PORT_27017_TCP_ADDR || 'localhost'
    mongo_port = argv.port || process.env.DB_PORT_27017_TCP_PORT || '27017'
    mongo_database = argv.database || 'graph'
    mongo_uri = "mongodb://#{mongo_host}:#{mongo_port}/#{mongo_database}"

    ConfigurationManager = require('graph-common').ConfigurationManager
    return new ConfigurationManager({
      name: "Piráti Open Graph API",
      di: {
        StorageManager: './storage_manager',
        SchemaManager: './schema_manager',
        NodeManager: './node_manager',
        RouterManager: './router_manager',
        GQL: './gql'
      },
      SchemaManager: {
        "Schema": "./schema_schema",
        "Node": "./node_schema",
        "Router": "./router_schema"
      },
      StorageManager: mongo_uri,
      NodeManager: {
        "": { name: "root", path: "", router: 'EchoRouter' },
        "echo": { name: "echo", path: "echo", router: 'EchoRouter' },
        "echo/redirect": { name: "redirect", path: "echo/redirect", router: 'RedirectRouter', configuration: { redirect: "echo" } },
        "node": { name: "node", path: "node", router: 'StorageRouter', configuration: { schema: "Node" } }
      },
      RouterManager: {
        "EchoRouter": { name: "EchoRouter", require: "./echo_router" },
        "RedirectRouter": { name: "RedirectRouter", require: "./redirect_router" },
        "StorageRouter": { name: "StorageRouter", require: "./storage_router" }
      },
    })

module.exports = CLI