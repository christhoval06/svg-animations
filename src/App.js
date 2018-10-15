import React, {Component} from 'react';

import {OrangeSvg} from './svg';
import {CountDownSection, CustomersSection, HomeSection, StripeSection} from './sections';
import {ArrowSeparatorElement, ShottingCoinAnimation} from "./components";

class App extends Component {
	render() {
		// (<OrangeSvg scale={1.5} className="App-logo"/>)
		return (
			<main>
				<HomeSection logo={null}/>
				<ArrowSeparatorElement/>
				<CountDownSection date={'21 october 2018 14:00:00'}/>
				<ArrowSeparatorElement className={'theme'}/>
				<CustomersSection/>
				{/* <StripeSection/> */}
			</main>
		);
	}
}

export default App;

// https://svgr.now.sh
