import React from 'react';
import PropTypes from 'prop-types';

const ArrowSeparatorElement = ({className = 'white'}) => (
	<div className={`arrow-separator arrow-${className}`}/>
);

ArrowSeparatorElement.propTypes = {
	className: PropTypes.oneOf(['white', 'theme', 'themelight', 'gray']),
};

export {ArrowSeparatorElement};
