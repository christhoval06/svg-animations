import React, {Component} from 'react';
import PropTypes from "prop-types";
import {interval} from "../utils/functions.utils";

class CountDownSection extends Component {

	static propTypes = {
		date    : PropTypes.string.isRequired,
		format  : PropTypes.bool,
		callback: PropTypes.func
	};

	static defaultProps = {
		format  : true,
		callback: () => null
	};

	state = {
		days   : '00',
		hours  : '00',
		minutes: '00',
		seconds: '00'
	};

	componentDidMount() {
		this.interval = setInterval(this.start.bind(this), 1000);
	}

	render() {
		const {days, hours, minutes, seconds} = this.state;
		const {format} = this.props;
		return (
			<div className="fullwidth colour1 clearfix">
				<div id="countdown" className="bodycontainer clearfix"
					 data-uk-scrollspy="{cls:'uk-animation-fade', delay: 300, repeat: true}">

					<div id="countdowncont" className="clearfix">
						<ul id="countscript">
							<li>
								<span ref="days" className="days">{this.value(days, format)}</span>
								<p>{this.label(days, 'Days', 'Day')}</p>
							</li>
							<li>
								<span ref="hours" className="hours">{this.value(hours, format)}</span>
								<p>{this.label(hours, 'Hours', 'Hour')}</p>
							</li>
							<li className="clearbox">
								<span ref="minutes" className="minutes">{this.value(minutes, format)}</span>
								<p>{this.label(minutes, 'Minutes', 'Minute')}</p>
							</li>
							<li>
								<span ref="seconds" className="seconds">{this.value(seconds, format)}</span>
								<p>{this.label(seconds, 'Seconds', 'second')}</p>
							</li>
						</ul>
					</div>

				</div>
			</div>
		);
	}

	start() {
		const {date, callback} = this.props;
		const eventDate = Date.parse(date) / 1000;
		const currentDate = Math.floor(Date.now() / 1000);

		if (eventDate <= currentDate) {
			callback.call(this);
			clearInterval(this.interval);
		}

		let seconds = eventDate - currentDate;
		const days = Math.floor(seconds / (60 * 60 * 24)); //calculate the number of days
		seconds -= days * 60 * 60 * 24; //update the seconds variable with no. of days removed
		const hours = Math.floor(seconds / (60 * 60));
		seconds -= hours * 60 * 60; //update the seconds variable with no. of hours removed
		const minutes = Math.floor(seconds / 60);
		seconds -= minutes * 60; //update the seconds variable with no. of minutes removed

		if (!isNaN(eventDate)) {
			this.setState({days, hours, minutes, seconds});
		} else {
			console.error("Invalid date. Here's an example: 12 Tuesday 2012 17:30:00");
			clearInterval(interval);
		}
	}

	label(number, plural, singular) {
		return number > 1 ? plural : singular;
	}

	value(number, format = false) {
		return number > 9 ? number : `0${number}`;
	}
}

export {CountDownSection};
