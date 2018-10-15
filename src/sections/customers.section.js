import React, {Component} from 'react';

class CustomersSection extends Component {

	state = {
		customers: [
			{
				className: "kickstarter",
				src      : "https://stripe.com/img/v3/home/customer-logos/kickstarter.svg",
			},
			{
				className: "instacart",
				src      : "https://stripe.com/img/v3/home/customer-logos/instacart.svg",
			},
			{
				className: "pinterest",
				src      : "https://stripe.com/img/v3/home/customer-logos/pinterest.svg",
			},
			{
				className: "lyft",
				src      : "https://stripe.com/img/v3/home/customer-logos/lyft.svg",
			},
			{
				className: "shopify",
				src      : "https://stripe.com/img/v3/home/customer-logos/shopify.svg",
			},
			{
				className: "opentable",
				src      : "https://stripe.com/img/v3/home/customer-logos/opentable.svg",
			},
			{
				className: "slack",
				src      : "https://stripe.com/img/v3/home/customer-logos/slack.svg",
			}
		]
	};

	render() {
		const {customers} = this.state;
		return (
			<section id="customer-logos" className="fullwidth colour3 clearfix">
				<a className="bodycontainer clearfix">
					<span className="common-Button common-Button--default" style={styles.button}>Conoce a nuestros clientes</span>
					<ul>
						{customers.map(customer => (
							<li key={customer.className}>
								<img {...customer} alt={customer.className}/>
							</li>
						))}
					</ul>
				</a>
			</section>
		);
	}
}

const styles = {
	button: {
		backgroundColor   : '#1ABC9C',
		color             : '#FFF',
		textDecoration    : 'none',
		display           : 'inline-block',
		fontSize          : 32,
		lineHeight        : '32px',
		padding           : '5px 12px',
		WebkitBorderRadius: 4,
		MozBorderRadius   : 4,
		borderRadius      : 4

	}
};

export {CustomersSection};
