# ⚖️ Crowdsourced Legal Guards

> 🛡️ Empowering communities to pool resources for legal defense of social causes

## 🎯 Overview

Crowdsourced Legal Guards is a decentralized platform built on the Stacks blockchain that enables communities to collectively fund legal defense for important social causes. Users can create legal defense cases, contribute STX tokens, and support causes they believe in.

## ✨ Features

- 🏛️ **Case Creation**: Create legal defense cases with target funding goals and deadlines
- 💰 **Crowd Funding**: Community members can contribute STX to support cases
- 📊 **Progress Tracking**: Real-time funding progress and contributor statistics
- ⏰ **Time-Limited Campaigns**: Cases have deadlines to create urgency
- 🔐 **Secure Withdrawals**: Only authorized beneficiaries can withdraw funds
- 🆘 **Emergency Refunds**: Contributors can get refunds if cases fail to meet minimum thresholds
- 📈 **User Statistics**: Track total contributions and cases supported

## 🚀 Quick Start

### Prerequisites

- Clarinet CLI installed
- Stacks wallet configured
- Basic understanding of Clarity smart contracts

### Installation

1. Clone this repository
2. Navigate to the project directory
3. Run `clarinet check` to verify contract syntax
4. Deploy using `clarinet deploy`

## 📋 Contract Functions

### 🏗️ Core Functions

#### Create Case
```clarity
(create-case "Case Title" "Description" target-amount beneficiary-principal duration-blocks)
```
Creates a new legal defense case with specified parameters.

#### Contribute to Case
```clarity
(contribute-to-case case-id amount)
```
Contribute STX tokens to support a specific case.

#### Withdraw Funds
```clarity
(withdraw-funds case-id)
```
Withdraw collected funds (only for beneficiary or case creator after deadline).

#### Close Case
```clarity
(close-case case-id)
```
Close an active case (only for case creator).

#### Emergency Refund
```clarity
(emergency-refund case-id)
```
Get refund if case failed to reach 50% of target after deadline.

### 📖 Read-Only Functions

#### Get Case Information
```clarity
(get-case case-id)
```
Returns complete case details including funding progress.

#### Get Contribution Details
```clarity
(get-contribution case-id contributor-principal)
```
Returns contribution amount and timestamp for a specific contributor.

#### Get Case Contributors
```clarity
(get-case-contributors case-id)
```
Returns list of all contributors for a case.

#### Get User Statistics
```clarity
(get-user-stats user-principal)
```
Returns total contributions and cases supported by a user.

#### Calculate Funding Progress
```clarity
(calculate-funding-progress case-id)
```
Returns funding progress as percentage (0-100).

## 💡 Usage Examples

### Creating a Legal Defense Case

```clarity
(contract-call? .legal-guards create-case 
  "Environmental Protection Lawsuit" 
  "Legal defense for community fighting industrial pollution"
  u1000000000
  'SP1ABCD1234567890
  u1008)
```

### Contributing to a Case

```clarity
(contract-call? .legal-guards contribute-to-case u1 u50000000)
```

### Checking Case Status

```clarity
(contract-call? .legal-guards get-case u1)
```

## 🔒 Security Features

- ✅ **Authorization Checks**: Only authorized users can perform sensitive operations
- 🚫 **Double Contribution Prevention**: Users cannot contribute to the same case twice
- ⏰ **Deadline Enforcement**: Cases automatically become inactive after deadline
- 💸 **Secure Transfers**: All STX transfers use built-in Stacks functions
- 🛡️ **Emergency Safeguards**: Refund mechanism protects contributor funds

## 📊 Data Structures

### Case Structure
- **Title**: Case name (max 128 characters)
- **Description**: Detailed description (max 512 characters)  
- **Target Amount**: Funding goal in micro-STX
- **Current Amount**: Current funding raised
- **Creator**: Case creator principal
- **Beneficiary**: Fund recipient principal
- **Deadline**: Block height deadline
- **Status**: Current case status (active/completed/closed)
- **Created At**: Creation block height

### Contribution Structure
- **Amount**: Contribution in micro-STX
- **Timestamp**: Block height of contribution

## 🎯 Use Cases

- 🌍 **Environmental Protection**: Fund legal action against polluters
- 👥 **Civil Rights**: Support discrimination and rights violation cases
- 🏠 **Housing Rights**: Defend against unfair evictions and housing discrimination
- 👨‍💼 **Workers' Rights**: Support labor law violations and workplace safety cases
- 🗳️ **Voting Rights**: Protect democratic processes and voter access

## ⚠️ Important Notes

- Contributions are final once made (except emergency refunds)
- Cases must reach at least 50% funding to prevent emergency refunds
- Only beneficiaries or case creators can withdraw funds
- All amounts are in micro-STX (1 STX = 1,000,000 micro-STX)
- Cases become inactive after their deadline

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests with `clarinet test`
5. Submit a pull request

## 📄 License

This project is open source and available under the MIT License.

## 🆘 Support

If you encounter issues or have questions:
- Open an issue on GitHub
- Check the Clarinet documentation
- Review the Stacks blockchain documentation

---

*Built with ❤️ for social justice and community empowerment*
