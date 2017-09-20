const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");

module.exports = {
    entry: "./frontend/index.js",
    output: {
        path: path.resolve(__dirname, "build"),
        filename: "bundle.js"
    },
    plugins: [new HtmlWebpackPlugin({
        template: "./frontend/html/index.html",
        inject: "body"
    })],
    module: {
        rules: [{
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: [{
                    loader: "elm-webpack-loader",
                    options: {
                        forceWatch: true
                    }
                }]
            },
                {
                    test: /\.png$/,
                    loader: 'url-loader',
                    query: {
                        mimetype: 'image/png',
                        name: './build/css/semantic/themes/default/assets/fonts/image.png'
                    }
                },
            {
                test: /\.svg$/,
                loader: 'url-loader',
                query: {
                    mimetype: 'image/svg+xml',
                    name: './build/css/semantic/themes/default/assets/fonts/icons.svg'
                }
            },

            {
                test: /\.woff$/,
                loader: 'url-loader',
                query: {
                    mimetype: 'application/font-woff',
                    name: './builjd/css/semantic/themes/default/assets/fonts/icons.woff'
                }
            },

            {
                test: /\.woff2$/,
                loader: 'url-loader',
                query: {
                    mimetype: 'application/font-woff2',
                    name: './build/css/semantic/themes/default/assets/fonts/icons.woff2'
                }
            },

            {
                test: /\.[ot]tf$/,
                loader: 'url-loader',
                query: {
                    mimetype: 'application/octet-stream',
                    name: './build/css/semantic/themes/default/assets/fonts/icons.ttf'
                }
            },

            {
                test: /\.eot$/,
                loader: 'url-loader',
                query: {
                    mimetype: 'application/vnd.ms-fontobject',
                    name: './build/css/semantic/themes/default/assets/fonts/icons.eot'
                }
            },
            {
                test: /\.css$/,
                use: ["style-loader", "css-loader"]
            },
            {
                test: /\.scss$/,
                exclude: [/node_modules/],
                use: [{
                        loader: "style-loader"
                    },
                    {
                        loader: "css-loader"
                    },
                    {
                        loader: "sass-loader"
                    }
                ]
            }
        ]
    },
    devServer: {
        contentBase: path.resolve(__dirname, "build"),
        port: 9000
    }
};
