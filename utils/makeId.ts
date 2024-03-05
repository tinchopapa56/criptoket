export const makeId = (Length: any) => {
    let res = '';

    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const charactersLength = characters.length;

    for (let i = 0; i < Length; i += 1) {
        res += characters.charAt(Math.floor(Math.random() * charactersLength));
    }

    return res;
};