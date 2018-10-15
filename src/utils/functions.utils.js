// utils
//
//

const pipe = (...functions) => arg => functions.reduce((a, b) => b(a), arg);

const define = (object, property, value) =>
	Object.defineProperty(object, property, {
		value,
		writable    : true,
		configurable: true,
		enumerable  : true
	});

const first = list => list[0];

const last = list => list[list.length - 1];

const getRandomInt = (min, max) =>
	Math.floor(Math.random() * (max - min)) + min;

const getRandom = (min, max) =>
	Math.random() * (max - min);

const interval = (callback, delay) => {
	const tick = now => {
		if (now - start >= delay) {
			start = now;
			callback();
		}
		requestAnimationFrame(tick);
	};
	let start = performance.now();
	requestAnimationFrame(tick);
};

export {
	pipe,
	define,
	first,
	last,
	getRandomInt,
	getRandom,
	interval
}
