import React from 'react'

type TBtnProps = {
    handleClick: () => any;
    classStyles?: string;
    btnText: string;
}

export const Button = ({handleClick, classStyles, btnText}: TBtnProps) => (
    <button
        type="button"
        className={`nft-gradient text-sm minlg:text-lg py-2 px-6 minlg:px-8 font-poppins font-semibold text-white ${classStyles}`}
        onClick={handleClick}
    >
    {btnText}
    </button>
)