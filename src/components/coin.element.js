import React, {Component} from 'react';
import PropTypes from 'prop-types';
import {define, getRandom} from "../utils";

const w = window.innerWidth,
	h = window.innerHeight;

class CoinElement extends Component {

	static propTypes = {
		size   : PropTypes.number,
		animate: PropTypes.bool,
		fliped : PropTypes.bool,
		style  : PropTypes.object
	};

	static defaultProps = {
		style  : {},
		animate: false,
		fliped : false,
		size   : 90
	};

	static initialState = () => ({
		x        : w / 2,
		y        : h * .1,
		vx       : (getRandom(0, 100) - 50) / 12,
		vy       : -(getRandom(50, 100)) / 9,
		lightness: getRandom(0, 50),
		alpha    : .1,
		fade     : .015,
		scale    : .01,
		growth   : .01,
		rotation : getRandom(0, Math.PI * 2),
		spin     : (getRandom(0, 100) - 50) / 300,
		styles   : {},
		started  : false
	});

	state = {
		tail: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/US_One_Cent_Rev.png/240px-US_One_Cent_Rev.png",
		head: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/US_One_Cent_Obv.png/240px-US_One_Cent_Obv.png",
		...CoinElement.initialState()
	};

	componentDidMount() {
		this.update();
	}

	render() {
		const {size, animate, fliped, style, ...props} = this.props;
		const {tail, head} = this.state;

		return (
			<div className={['coin-flip', fliped && 'fliped', animate && 'animated',].join(' ')} ref="icon" {...props}
				 style={{...style, ...this.initialStyle()}}>
				<div className="tails">
					<img src={tail} alt="tail" style={{width: `${size}px`}}/>
				</div>
				<div className="heads">
					<img src={head} alt="head" style={{width: `${size}px`}}/>
				</div>
			</div>);
	}

	initialStyle = () => {
		const {animate} = this.props;
		const {styles, started, scale} = this.state;

		if (animate && !started) {
			return {
				...styles, ...{
					transform: `scale(${scale})`
				}
			}
		}
		return styles
	};

	reset() {
		this.setState({...CoinElement.initialState()});
		this.update();
	}

	update() {
		const {animate} = this.props;

		if (animate) {
			const {growth, spin} = this.state;
			let {x, y, vx, vy, scale, alpha, fade, rotation} = this.state;

			const transform = {};

			const tick = () => {
				x += vx;
				y += vy;
				vy += .15 * scale;
				if (alpha < 1) {
					alpha += fade;
				}
				scale += growth;
				rotation += spin;

				define(transform, "translateX", x);
				define(transform, "translateY", y);
				define(transform, "rotate", rotation);
				define(transform, "scale", scale);

				this.setState({
					x, y, vx, vy, alpha, fade, scale, rotation,
					started: true,
					styles : {
						transform: Object.keys(transform).map(key => {
							const value = transform[key];
							const unit = /rotate/.test(key) ? "deg" : (/scale/.test(key) ? '' : "px");
							return `${key}(${value}${unit})`;
						}).join(" ")
					}
				});

				return (y - 30 >= h) ? this.reset() : requestAnimationFrame(tick);
			};

			requestAnimationFrame(tick);
		}
	}
}

export {CoinElement};
