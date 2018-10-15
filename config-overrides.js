const ExtractTextPlugin = require("extract-text-webpack-plugin");
//const webpack = require('webpack');

module.exports = (config, env) => {

	/*
		const resolvers = {
			jquery   : "jquery/dist/jquery"
		};
		*/

	const rules = [
		{
			test  : /[\/\\]node_modules[\/\\]some-module[\/\\]index\.js$/,
			loader: "imports-loader?this=>window"
		},
		{
			use    : ExtractTextPlugin.extract({
				fallback: "style-loader",
				use     : [
					'css-loader', //knows how to deal with css
					'autoprefixer-loader?browsers=last 3 versions',
					'sass-loader?outputStyle=expanded' //this one is applied first.
				]
			}),
			test   : /\.scss$/,
			exclude: /node_modules/
		},
		{
			test: /\.(jpe?g|woff|woff2|eot|ttf|svg)(\?.*$|$)/,
			use : 'file-loader'
		},
		{
			test  : /\.jpe?g$|\.gif$|\.png$|^(?!.*\.inline\.svg$).*\.svg$/,
			loader: 'url-loader'
		}
	];

	const plugins = [
		new ExtractTextPlugin("./css/main.css", {
			allChunks: false
		}),
		/*
		new webpack.ProvidePlugin({
			$              : "jquery",
			jQuery         : "jquery",
			"window.jQuery": "jquery"
		})
		*/
	];

	rules.forEach(rule => config.module.rules.push(rule));
	plugins.forEach(plugin => config.plugins.push(plugin));

	/*
	Object.entries(resolvers).forEach(
		([alias, resolver]) => config.resolve.alias[alias] = resolver
	);
	*/

	return config
};
