import React, {Component} from 'react';
import PropTypes from 'prop-types';

import {define, easeOutQuart, getRandomInt, interval, pipe} from '../utils';
import {CogWheelsSvg, FastForwardSvg, OrangeSvg} from "../svg";
import {CoinElement} from "./coin.element";

// http://jsfiddle.net/z3roj35k/1/

class AnimationItem extends Component {

	static propTypes = {
		language: PropTypes.oneOfType([PropTypes.string.isRequired, PropTypes.element.isRequired]),
	};

	state = {};

	componentDidMount() {
		this.animateIcon();
	}

	render() {
		const {language} = this.props;
		const {style} = this.state;
		return React.cloneElement(language, {ref: (el) => this.$node = (el ? el.refs.icon : null), style});
	}

	getRandomY(x, min, max) {
		if (Math.abs(x) > min) return getRandomInt(-max, max);
		const minY = Math.sqrt(Math.pow(min, 2) - Math.pow(x, 2));
		const randomSign = Math.round(Math.random()) * 2 - 1;
		return randomSign * getRandomInt(minY, max);
	}

	animateIcon() {
		const time = {total: 12000};
		const maxDistance = 120;
		const maxRotation = 800;
		const transform = {};

		define(transform, "translateX", getRandomInt(-maxDistance, maxDistance));
		define(transform, "translateY", this.getRandomY(transform.translateX, 60, maxDistance));
		define(transform, "rotate", getRandomInt(-maxRotation, maxRotation));
		// define(transform, "scale", 1);

		const tick = now => {
			if (time.start == null) define(time, "start", now);
			define(time, "elapsed", now - time.start);
			const progress = easeOutQuart(time.elapsed, 0, 1, time.total);

			this.setState({
				style: {
					opacity  : Math.abs(1 - progress),
					transform: Object.keys(transform).map(key => {
						const unit = /rotate/.test(key) ? "deg" : (/scale/.test(key) ? null : "px");
						const value = transform[key] * progress;
						return `${key}(${value}${unit ? unit : ''})`;
					}).join(" ")
				}
			});

			return time.elapsed < time.total
				? requestAnimationFrame(tick)
				: (this.$node ? this.$node.remove() : null);

		};

		requestAnimationFrame(tick);
	}
}

class AnimationElement extends Component {

	state = {
		icons   : [
			<OrangeSvg scale={.6}/>,
			<FastForwardSvg animate={true} scale={.6}/>,
			<CogWheelsSvg animate={true} scale={.6}/>,
			<CoinElement animate={false} fliped={true} size={30}/>
		],
		selected: []
	};

	componentDidMount() {
		interval(pipe(this.getRandomLanguage.bind(this)), 500);
	}

	render() {
		const {selected} = this.state;
		return (
			<div className="pop-animation">
				{selected.map((item, index) => (<AnimationItem key={index} language={item}/>))}
			</div>
		);
	}

	getRandomLanguage() {
		const {icons, selected} = this.state;
		const item = icons[getRandomInt(0, icons.length)];
		selected.push(item);
		this.setState({selected});
	}

}

export {AnimationElement};
