import React from 'react';
import {CogWheelsSvg, FastForwardSvg} from "../svg";

const StripeSection = (props) => (
	<section id="developers-first">
		<h2 className="common-UppercaseTitle" style={{position: 'relative'}}>
			<CogWheelsSvg className="heading-icon" animate={true} scale={3}/>
		</h2>

		<FastForwardSvg className="heading-icon" animate={true} scale={3}/>

	</section>
);

export {StripeSection};
