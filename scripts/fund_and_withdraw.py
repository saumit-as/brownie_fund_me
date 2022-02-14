from brownie import FundMe, accounts
from .helpful_scripts import get_account


def fund():
    fund_me = FundMe[-1]
    account = get_account()
    entrance_fee = fund_me.getEntranceFee() + 100
    print(f"The current entry fee is {entrance_fee}")
    print("Funding")
    fund_me.fund({"from": account, "value": entrance_fee})


def widthdraw():
    fund_me = FundMe[-1]
    account = get_account()
    fund_me.widthdraw({"from": account})


def main():
    fund()
    widthdraw()
