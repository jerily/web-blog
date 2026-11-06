# Same entry point, source location, options and callbacks as every web package.
proc ::web::blog::mount {router args} {::web::content::mount blog $router {*}$args}
proc ::web::blog::create {args} {::web::content::create blog {*}$args}
proc ::web::blog::sync {store directory} {::web::content::sync $store $directory}
proc ::web::blog::load {store path} {::web::content::load $store $path}
proc ::web::blog::posts {store} {::web::content::posts $store}
proc ::web::blog::history {store path} {::web::content::history $store $path}
proc ::web::blog::save {store path title markdown revision} {
    ::web::content::save $store $path $title $markdown $revision
}
