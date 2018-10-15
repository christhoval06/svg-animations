import React, {Component} from 'react';
import PropTypes from 'prop-types';

import {define} from '../utils/functions.utils';

class CogWheelsSvg extends Component {

	static propTypes = {
		scale  : PropTypes.number,
		animate: PropTypes.bool
	};

	static defaultProps = {
		scale  : 1,
		animate: false
	};

	state = {
		duration: 15000,
		turn    : 360,
		state   : {}
	};

	componentDidMount() {
		const {animate} = this.props;
		if (animate) {
			this.$node = this.refs.icon;
			this.cogwheels = Array.from(
				this.$node.querySelectorAll("path"), (element, index) => ({
					element,
					center   : this.findRotationCenter(element),
					direction: index ? -1 : 1
				}));
			requestAnimationFrame(this.rotate.bind(this));
		}
	}

	render() {
		const {scale, animate, ...props} = this.props;

		return (
			<svg ref="icon"
				 xmlns="http://www.w3.org/2000/svg"
				 width={`${67 * scale}px`}
				 height={`${67 * scale}px`}
				 viewBox='0 0 67 67'
				 {...props}>
				<g fill="none" fillRule="evenodd" scale={scale} className={`${animate && 'animated'}`}>
					<circle fill="#B9F4BC" cx="33" cy="33" r="33"/>
					<path ref="cogwheel1"
						  d="M38.4 15l1-3h1l1.2 3c.2.2.5.2.7.3l2.2-2.5 1 .4-.2 3.3c.2 0 .3.2.5.4l3-1.5.7.7-1.4 3 .5.5h3.3l.4.8-2.5 2.2c0 .2 0 .5.2.7l3 1v1l-3 1.2-.3.8 2.5 2-.4 1-3.3-.2-.4.7 1.5 2.8-.7.7-3-1.4c0 .2-.4.4-.6.5l.2 3.3-1 .4-2-2.5c-.3 0-.6 0-1 .2l-1 3h-1l-1-3c-.2-.2-.5-.2-.8-.3l-2 2.5-1-.4.2-3.3-.7-.4-2.8 1.5-.7-.7 1.4-3c-.2 0-.4-.4-.5-.6l-3.3.2-.4-1 2.5-2c0-.3 0-.6-.2-1l-3-1v-1l3-1c.2-.2.2-.4.3-.7l-2.5-2.2.4-1 3.3.2c0-.2.2-.3.4-.5l-1.5-3 .7-.7 3 1.4.5-.5v-3.3l.8-.4 2.2 2.5s.5 0 .7-.2z"
						  fill="#6ED69A"/>
					<circle fill="#B9F4BC" cx="40" cy="25" r="2"/>
					<path ref="cogwheel2"
						  d="M21.6 26.8L19 25l-1.3 1 1.4 3c0 .2-.3.4-.5.6l-3-.8-1 1.4 2.4 2.3-.4.8-3.2.3-.3 1.6 3 1.4v.8l-3 1.4.4 1.6 3.2.3c0 .3.2.5.3.8l-2.4 2.3.8 1.4 3-.8.7.6-1.3 3 1.3 1 2.6-1.8c.3 0 .5.3.8.4l-.3 3.2 1.6.6 2-2.7c.2 0 .5 0 .7.2l1 3h1.5l1-3c0-.2.4-.2.7-.3l2 2.7 1.4-.6-.4-3.2c.3 0 .5-.3.8-.4L37 49l1.3-1-1.4-3c0-.2.3-.4.5-.6l3 .8 1-1.4-2.4-2.3.4-.8 3.2-.3.3-1.6-3-1.4v-.8l3-1.4-.4-1.6-3.2-.3c0-.3-.2-.5-.3-.8l2.4-2.3-.8-1.4-3 .8-.7-.6 1.3-3-1.3-1-2.6 1.8c-.3 0-.5-.3-.8-.4l.3-3.2-1.6-.6-2 2.7c-.2 0-.5 0-.7-.2l-1-3h-1.5l-1 3c0 .2-.4.2-.7.3l-2-2.7-1.4.6.4 3.2c-.3 0-.5.3-.8.4z"
						  fill="#1BB978"/>
					<circle fill="#B9F4BC" cx="28" cy="37" r="3"/>
				</g>

				Los desarrolladores ante todo
			</svg>
		);
	}

	findRotationCenter(element) {
		return ["x", "y"].reduce((coordinates, axis) => {
			const center = `c${axis}`;
			const separator = coordinates.length ? " " : "";
			return coordinates + separator + element.nextElementSibling.getAttribute(center);
		}, "");
	}

	rotate(now) {
		const {state, turn, duration} = this.state;
		if (state.start == null) define(state, "start", now);
		define(state, "elapsed", now - state.start);
		define(state, "progress", state.elapsed / duration);

		const rotation = Math.min(turn * state.progress, turn);
		this.cogwheels.forEach(object =>
			object.element.setAttribute(
				"transform", `rotate(${rotation * object.direction} ${object.center})`));

		if (rotation === turn) delete state.start;
		requestAnimationFrame(this.rotate.bind(this));
	};
}

export {CogWheelsSvg};
