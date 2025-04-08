def cmpl-scp [cmd: string, offset: int] {
    let argv = ($cmd | str substring ..<$offset | split row ' ')
    let p = if ($argv | length) > 2 { $argv | get 2 } else { $argv | get 1 }
    let ssh = (ssh-hosts | get completion
        | each {|x| {value: $"($x.value):" description: $x.uri} }
    )
    let n = ($p | split row ':')
    if $"($n | get 0):" in ($ssh | get value) {
        ^ssh ($n | get 0) $"sh -c 'ls -dp ($n | get 1)*'"
        | lines
        | each {|x| $"($n | get 0):($x)"}
    } else {
        let files = (do -i {
            ls -a ($"($p)*" | into glob)
            | each {|x| if $x.type == dir { $"($x.name)/"} else { $x.name }}
        })
        $files | append $ssh
    }
}

def expand-exists [p] {
    if ($p | path exists) {
        $p | path expand
    } else {
        $p
    }
}

export def --wrapped main [
    lhs: string@cmpl-scp,
    rhs: string@cmpl-scp
    ...opts
] {
    ^scp -r ...$opts (expand-exists $lhs) (expand-exists $rhs)
}
