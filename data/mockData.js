export const mockUsers = [
    { id: 'u1', name: 'Grant', avatar: 'G' },
    { id: 'u2', name: 'Sarah', avatar: 'S' },
    { id: 'u3', name: 'Mike', avatar: 'M' },
];

export const mockFeed = [
    {
        id: 'f1',
        userId: 'u2',
        userName: 'Sarah',
        date: '2025-12-29T08:30:00',
        imageUrl: 'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3', // Open book placeholder
        caption: 'Done with Rev 6-10! Heavy stuff.',
        likes: 2
    },
    {
        id: 'f2',
        userId: 'u3',
        userName: 'Mike',
        date: '2025-12-29T07:15:00',
        imageUrl: 'https://images.unsplash.com/photo-1491841550275-ad7854e35ca6?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3', // Coffee and book
        caption: 'Early morning reading.',
        likes: 5
    }
];
