import React, {Component} from 'react';
import PropTypes from 'prop-types';
import {interval, pipe} from "../utils";
import {CoinElement} from "./coin.element";

class ShottingCoinAnimation extends Component {

	static propTypes = {
		count: PropTypes.number
	};

	static defaultProps = {
		count: 100
	};

	state = {
		coins: [],
		tick : 0
	};

	componentDidMount() {
		const {tick} = this.props;
		this.setState({tick});
		interval(pipe(this.createCoin.bind(this)), 3);
	}

	render() {
		const {coins} = this.state;
		return (
			<div className="shotting-coins" {...this.props} style={{position: 'relative', height: '66px'}}>
				{coins.map((coin, index) => React.cloneElement(coin, {key: index}))}
			</div>
		);
	}

	createCoin() {
		const {coins} = this.state;
		const {count} = this.props;
		if (coins.length < count) {
			coins.push(<CoinElement size={90} animate={true} fliped={true}/>);
			this.setState({coins});
		}
	}
}

export {ShottingCoinAnimation};
