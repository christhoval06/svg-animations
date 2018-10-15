//
// easing equations
// ===============================================================================================
//

/**
 * simple linear tweening - no easing, no acceleration
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const linearTween = (t, b, c, d) =>
	c * t / d + b;

/**
 * quadratic easing in - accelerating from zero velocity
 * @param t
 * @param b
 * @param c
 * @param d
 */
const easeInQuad = (t, b, c, d) =>
	c * (t /= d) * t + b;

/**
 * quadratic easing out - decelerating to zero velocity
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeOutQuad = (t, b, c, d) =>
	-c * (t /= d) * (t - 2) + b;

/**
 * quadratic easing in/out - acceleration until halfway, then deceleration
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeInOutQuad = (t, b, c, d) => {
	if ((t /= d / 2) < 1) return c / 2 * t * t + b;
	t--;
	return -c / 2 * (t * (t - 2) - 1) + b;
};

/**
 * cubic easing in - accelerating from zero velocity
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeInCubic = (t, b, c, d) =>
	c * (t /= d) * Math.pow(t, 2) + b;

/**
 * cubic easing out - decelerating to zero velocity
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeOutCubic = (t, b, c, d) => {
	t /= d;
	t--;
	return c * (Math.pow(t, 3) + 1) + b;
};

/**
 * cubic easing in/out - acceleration until halfway, then deceleration
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeInOutCubic = function(t, b, c, d) {
	if ((t /= d / 2) < 1) return c / 2 * Math.pow(t, 3) + b;
	t -= 2;
	return c / 2 * (Math.pow(t, 3) + 2) + b;
};

/**
 * quadratic easing in - accelerating from zero velocity
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeInQuart = (t, b, c, d) =>
	c * (t /= d) * Math.pow(t, 3) + b;

/**
 * quadratic easing out - decelerating to zero velocity
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeOutQuart = (t, b, c, d) =>
	-c * ((t = t / d - 1) * Math.pow(t, 3) - 1) + b;

/**
 * quadratic easing in/out - acceleration until halfway, then deceleration
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeInOutQuart = (t, b, c, d) => {
	if ((t /= d / 2) < 1) return c / 2 * Math.pow(t, 4) + b;
	return -c / 2 * ((t -= 2) * Math.pow(t, 3) - 2) + b;
};

/**
 * quintic easing in - accelerating from zero velocity
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeInQuint = (t, b, c, d) =>
	c * Math.pow((t /= d), 5) + b;

/**
 * quintic easing out - decelerating to zero velocity
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeOutQuint = (t, b, c, d) => {
	t /= d;
	t--;
	return c * (Math.pow(t, 5) + 1) + b;
};

/**
 * quintic easing in/out - acceleration until halfway, then deceleration
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeInOutQuint = (t, b, c, d) => {
	t /= d / 2;
	if (t < 1) return c / 2 * Math.pow(t, 5) + b;
	t -= 2;
	return c / 2 * (Math.pow(t, 5) + 2) + b;
};

/**
 *  sinusoidal easing in - accelerating from zero velocity
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeInSine = (t, b, c, d) =>
	-c * Math.cos(t / d * (Math.PI / 2)) + c + b;

/**
 * sinusoidal easing out - decelerating to zero velocity
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeOutSine = (t, b, c, d) =>
	c * Math.sin(t / d * (Math.PI / 2)) + b;

/**
 * sinusoidal easing in/out - accelerating until halfway, then decelerating
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeInOutSine = (t, b, c, d) =>
	-c / 2 * (Math.cos(Math.PI * t / d) - 1) + b;

/**
 * exponential easing in - accelerating from zero velocity
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeInExpo = (t, b, c, d) =>
	c * Math.pow(2, 10 * (t / d - 1)) + b;

/**
 *  exponential easing out - decelerating to zero velocity
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeOutExpo = (t, b, c, d) =>
	c * (-Math.pow(2, -10 * t / d) + 1) + b;

/**
 * exponential easing in/out - accelerating until halfway, then decelerating
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeInOutExpo = (t, b, c, d) => {
	t /= d / 2;
	if (t < 1) return c / 2 * Math.pow(2, 10 * (t - 1)) + b;
	t--;
	return c / 2 * (-Math.pow(2, -10 * t) + 2) + b;
};

/**
 * circular easing in - accelerating from zero velocity
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeInCirc = (t, b, c, d) => {
	t /= d;
	return -c * (Math.sqrt(1 - Math.pow(t, 2)) - 1) + b;
};

/**
 * circular easing out - decelerating to zero velocity
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeInOutCirc = (t, b, c, d) => {
	t /= d / 2;
	if (t < 1) return -c / 2 * (Math.sqrt(1 - Math.pow(t, 2)) - 1) + b;
	t -= 2;
	return c / 2 * (Math.sqrt(1 - Math.pow(t, 2)) + 1) + b;
};

/**
 * circular easing in/out - acceleration until halfway, then deceleration
 * @param t
 * @param b
 * @param c
 * @param d
 * @return {*}
 */
const easeOutCirc = (t, b, c, d) => {
	t /= d;
	t--;
	return c * Math.sqrt(1 - Math.pow(t, 2)) + b;
};

const easeInBack = (x, t, b, c, d, s) => {
	if (s === undefined) s = 1.70158;
	return c * (t /= d) * t * ((s + 1) * t - s) + b;
};

const easeOutBack = (x, t, b, c, d, s) => {
	if (s === undefined) s = 1.70158;
	return c * ((t = t / d - 1) * t * ((s + 1) * t + s) + 1) + b;
};

const easeInOutBack = (t, b, c, d, s) => {
	if (s === undefined) s = 1.70158;
	if ((t /= d / 2) < 1) return c / 2 * (t * t * (((s *= (1.525)) + 1) * t - s)) + b;
	return c / 2 * ((t -= 2) * t * (((s *= (1.525)) + 1) * t + s) + 2) + b;
};

const easeInElastic = (x, t, b, c, d, s) => {
	if (s === undefined) s = 1.70158;
	let p = 0, a = c;
	if (t === 0) return b;
	if ((t /= d) === 1) return b + c;
	if (!p) p = d * .3;
	if (a < Math.abs(c)) {
		a = c;
		s = p / 4;
	}
	else s = p / (2 * Math.PI) * Math.asin(c / a);
	return -(a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p)) + b;
};

const easeOutElastic = (t, b, c, d, frequency = 700) => {
	if (t === 0 || c === 0) return b;
	if ((t /= d) === 1) return b + c;
	const a = c;
	const p = d * (1 - Math.min(frequency, 999) / 1000);
	const s = a < Math.abs(c) ? p / 4 : p / (2 * Math.PI) * Math.asin(c / a);
	return a * Math.pow(2, -10 * t) * Math.sin((t * d - s) * (2 * Math.PI) / p) + c + b;
};

const easeOutBounce = (x, t, b, c, d) => {
	if ((t /= d) < (1 / 2.75)) {
		return c * (7.5625 * t * t) + b;
	} else if (t < (2 / 2.75)) {
		return c * (7.5625 * (t -= (1.5 / 2.75)) * t + .75) + b;
	} else if (t < (2.5 / 2.75)) {
		return c * (7.5625 * (t -= (2.25 / 2.75)) * t + .9375) + b;
	} else {
		return c * (7.5625 * (t -= (2.625 / 2.75)) * t + .984375) + b;
	}
};

export {
	linearTween,
	easeInQuad,
	easeOutQuad,
	easeInOutQuad,
	easeInCubic,
	easeOutCubic,
	easeInOutCubic,
	easeInQuart,
	easeOutQuart,
	easeInOutQuart,
	easeInQuint,
	easeOutQuint,
	easeInOutQuint,
	easeInSine,
	easeOutSine,
	easeInOutSine,
	easeInExpo,
	easeOutExpo,
	easeInOutExpo,
	easeInCirc,
	easeOutCirc,
	easeInOutCirc,
	easeInBack,
	easeOutBack,
	easeInOutBack,
	easeInElastic,
	easeOutElastic,
	easeOutBounce
}
