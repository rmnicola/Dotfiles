alias rcfcp="rclone copy --drive-chunk-size 512M --max-backlog 999999 --fast-list \
-v --checkers 5 --transfers 30 --stats 30s"

alias rcfsync="rclone sync --drive-chunk-size 512M --max-backlog 999999 --fast-list \
-v --checkers 5 --transfers 30 --stats 30s --create-empty-src-dirs"
