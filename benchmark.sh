set -e
set -o pipefail

#export MOZCONFIG=/home/matthew/mozconfigs/opt_browser_nodebug.mozconfig
export MOZCONFIG=/Users/mgaudet/mozconfigs/opt_browser.mozconfig

for fxver in  67 87 97 107;
do
    cat <<- EOF > babel.config.json
    {
    "presets": [
        [
            "@babel/preset-env",
            {
                "targets": [
                    "firefox $fxver",
                ],
                "debug": true,
                "modules": "auto",
            }
        ],
        "@babel/preset-react",
        "@babel/preset-typescript",
    ],
    "plugins": [
        [
            "@babel/plugin-proposal-decorators",
            {
                "legacy": true
            }
        ],
        "@babel/plugin-proposal-export-default-from",
        "@babel/plugin-proposal-numeric-separator",
        "@babel/plugin-proposal-class-properties",
        "@babel/plugin-proposal-object-rest-spread",
        "@babel/plugin-proposal-optional-chaining",
        "@babel/plugin-proposal-nullish-coalescing-operator",
        "@babel/plugin-syntax-dynamic-import",
    ],
    }
EOF

    npm run build | tee npm.build.log.$fxver

    pushd ~/unified/

    time ./mach raptor-test -t matrix-react-bench  --binary /Applications/Firefox.app/Contents/MacOS/firefox --is-release-build | tee benchmarkLog.$fxver &&  cp ./testing/mozharness/build/raptor.json  ~/perf/matrix-react-bench/fxversion-exploration/firefox-$fxver.json

    popd

done;
