import React from 'react';
import PropTypes from 'prop-types';
import {AnimationElement} from "../components";

const HomeSection = ({logo, ...props}) => (
	<div className="fullwidth clearfix">
		<div id="topcontainer" className="bodycontainer clearfix"
			 data-uk-scrollspy="{cls:'uk-animation-fade', delay: 300, repeat: true}">

			{/* <AnimationElement/> */}
			<p style={{position: 'relative'}}>{logo}</p>
			<h1><span>Pokemon Comunity Day</span><br/>is coming soon</h1>
			<p>It's almost ready ... honest</p>
		</div>
	</div>
);

HomeSection.propTypes = {
	logo: PropTypes.element.isRequired,
};

export {HomeSection};
