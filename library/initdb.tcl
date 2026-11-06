# Explicit schema setup on a caller-owned connection; safe to repeat.
proc ::web::blog::initdb {connection} {::web::content::initdb $connection}
