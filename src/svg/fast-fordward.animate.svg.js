import React, {Component} from 'react';
import PropTypes from 'prop-types';
import {easeInOutBack, easeInOutQuart, easeInQuart, first, interval, last, pipe} from "../utils";

class FastForwardSvg extends Component {

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
			this.$node = this.refs.icon.querySelector("g");
			this.paths = this.$node.getElementsByTagName("path");
			this.styles = {
				fills: [this.getRGB(first(this.paths)), this.getRGB(last(this.paths))],
				delta: this.getTranslateX(last(this.paths)),
				scale: {
					ratio: .5,
					cy   : this.$node.querySelector("circle").getAttribute("r") / 2
				}
			};
			interval(this.trigger.bind(this), 4000);
		}
	}

	render() {
		const {scale, animate, ...props} = this.props;

		return (
			<svg ref="icon" xmlns="http://www.w3.org/2000/svg"
				 width={`${67 * scale}px`}
				 height={`${67 * scale}px`}
				 viewBox='0 0 67 67'
				 {...props}>
				<g fill="none" fillRule="evenodd" scale={scale} className={`${animate && 'animated'}`}>
					<circle fill="#B9F4BC" cx="33" cy="33" r="33"/>
					<path d="M20 24c0-1.7 1-2.3 2.5-1.3l13 8.6c1.4 1 1.4 2.4 0 3.4l-13 8.6c-1.4 1-2.5.4-2.5-1.3V24"
						  fill="rgb(110, 214, 154)"/>
					<path d="M20 24c0-1.7 1-2.3 2.5-1.3l13 8.6c1.4 1 1.4 2.4 0 3.4l-13 8.6c-1.4 1-2.5.4-2.5-1.3V24"
						  transform="translate(12)" fill="rgb(27, 185, 120)"/>
				</g>
			</svg>
		);
	}

	getRGB = path =>
		path.getAttribute("fill").match(/\d+/g).map(Number);

	setRGB = (path, values) => {
		const [r, g, b] = values.map(Math.round);
		path.setAttribute("fill", `rgb(${r},${g},${b})`);
		return path;
	};

	getTranslateX = (() => {
		const extractNumber = pipe(first, Number);
		return path => extractNumber(/\d+/.exec(path.getAttribute("transform")));
	})();

	animations = {
		move(arrow, start, duration, self) {
			const tick = now => {
				const elapsed = now - start;
				const rgb = first(self.styles.fills).map((value, index) =>
					easeInQuart(elapsed, value, last(self.styles.fills)[index] - value, duration));
				const x = easeInOutBack(elapsed, 0, self.styles.delta, duration, 4);
				self.setRGB(arrow, rgb).setAttribute("transform", `translate(${x})`);
				if (elapsed < duration) requestAnimationFrame(tick);
			};
			requestAnimationFrame(tick);
		},
		leave(arrow, start, duration, self) {
			const tick = now => {
				const elapsed = now - start;
				const opacity = Math.max(0, easeInQuart(elapsed, 1, -1, duration));
				const scale = easeInQuart(elapsed, 1, -self.styles.scale.ratio, duration);
				const x = easeInQuart(elapsed, self.styles.delta, 80, duration);
				const y = easeInQuart(elapsed, 0, self.styles.scale.cy, duration);
				arrow.setAttribute("fill-opacity", opacity);
				arrow.setAttribute("transform", `translate(${x} ${y}) scale(${scale})`);
				elapsed < duration ? requestAnimationFrame(tick) : self.$node.removeChild(arrow);
			};
			requestAnimationFrame(tick);
		},
		enter(arrow, start, duration, self) {
			const tick = now => {
				const elapsed = now - start;
				const opacity = easeInOutQuart(elapsed, 0, 1, duration);
				const scale = easeInOutQuart(elapsed, self.styles.scale.ratio, self.styles.scale.ratio, duration);
				const x = easeInOutQuart(elapsed, -40, 40, duration);
				const y = easeInOutQuart(elapsed, self.styles.scale.cy, -self.styles.scale.cy, duration);
				arrow.setAttribute("fill-opacity", opacity);
				arrow.setAttribute("transform", `translate(${x} ${y}) scale(${scale})`);
				if (elapsed < duration) requestAnimationFrame(tick);
			};
			requestAnimationFrame(tick);
		}
	};

	trigger = () => {
		const arrows = {
			move : first(this.paths),
			leave: last(this.paths),
			enter: first(this.paths).cloneNode()
		};

		this.$node.insertBefore(arrows.enter, arrows.move).setAttribute("fill-opacity", 0);
		Object.keys(arrows).forEach(type => this.animations[type](arrows[type], performance.now(), 700, this));
	}
}

export {FastForwardSvg};
