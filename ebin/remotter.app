{application, remotter,
[{description, "Remote interface for Twitter"},
 {vsn, "0.1.1"},
 {modules, [
   remotter_app,
   remotter_sup,
   remotter_server
 ]},
 {registered, [remotter_sup]},
 {applications, [kernel, stdlib]},
 {mod, {remotter_app, []}}
]}.

