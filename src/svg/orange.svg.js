import React, {Component} from 'react';
import PropTypes from 'prop-types';

class OrangeSvg extends Component {

	static propTypes = {
		leaf  : PropTypes.string,
		orange: PropTypes.string,
		scale : PropTypes.number
	};

	static defaultProps = {
		leaf  : '#E26927',
		orange: '#6FB148',
		scale : 1
	};

	render() {
		const {leaf, orange, scale, ...props} = this.props;

		return (
			<svg
				ref="icon"
				xmlns="http://www.w3.org/2000/svg"
				width={`${48 * scale}px`}
				height={`${54 * scale}px`}
				viewBox="0 0 48 54"
				{...props}>
				<g fill="none" fillRule="evenodd" scale={scale}>
					<path fill={orange}
						  d="M33.4771,0.2295 C27.6031,0.2295 23.8871,5.5705 23.8871,5.5705 C23.8871,5.5705 27.6031,10.9105 33.4771,10.9105 C39.3511,10.9105 42.7071,5.5705 42.7071,5.5705 C42.7071,5.5705 39.3511,0.2295 33.4771,0.2295"/>
					<path fill={leaf}
						  d="M41.6284,14.3213 C38.3924,16.1193 36.1144,17.1983 29.5214,15.9993 C23.6074,14.9243 18.9514,8.1653 18.0524,6.7803 C7.8994,9.3753 0.3914,18.5833 0.3914,29.5463 C0.3914,42.5213 10.9104,53.0413 23.8864,53.0413 C36.8634,53.0413 47.3824,42.5213 47.3824,29.5463 C47.3824,23.7073 45.2484,18.3703 41.7234,14.2603 C41.6914,14.2793 41.6604,14.3033 41.6284,14.3213"/>
				</g>
			</svg>
		);
	}
}

export {OrangeSvg};
