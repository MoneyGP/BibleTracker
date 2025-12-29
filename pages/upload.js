import { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/router';
import { supabase } from '@/lib/supabaseClient';
import { useAuth } from '@/contexts/AuthContext';
import { compressImage } from '@/utils/compressImage';
import Layout from '@/components/Layout';
import Button from '@/components/Button';
import Card from '@/components/Card';
import { getTodaysReading } from '@/data/readingPlan';

export default function UploadPage() {
    const router = useRouter();
    const { reading: readingParam } = router.query; // Renamed to avoid conflict with state variable
    const { user, loading } = useAuth();
    const fileInputRef = useRef(null);
    const [reading, setReading] = useState(null); // This state will hold the full reading object from fullPlan
    const [selectedImage, setSelectedImage] = useState(null); // Base64 string for preview
    const [selectedFile, setSelectedFile] = useState(null); // Actual File object for upload
    const [previewUrl, setPreviewUrl] = useState(null);
    const [caption, setCaption] = useState('');
    const [uploading, setUploading] = useState(false);
    const [isSubmitting, setIsSubmitting] = useState(false);

    // Protect route
    useEffect(() => {
        if (!loading && !user) {
            router.replace('/');
        }
    }, [user, loading, router]);

    useEffect(() => {
        if (router.isReady) {
            if (readingParam) {
                // Find full context from plan
                import('@/data/fullPlan').then(mod => {
                    const found = mod.fullPlan.find(p => p.reading === readingParam);
                    setReading(found || { reading: readingParam, day: '?', date: new Date().toISOString() });
                });
            } else {
                import('@/data/fullPlan').then(mod => {
                    const todayStr = new Date().toISOString().split('T')[0];
                    const found = mod.fullPlan.find(p => p.date === todayStr);
                    setReading(found || mod.fullPlan[0]);
                });
            }
        }
    }, [router.isReady, router.query]);

    if (loading) return <Layout><div style={{ padding: 20 }}>Loading User...</div></Layout>;
    if (!user) return null; // Will redirect via effect

    const handleNextDay = () => {
        if (!reading || !reading.day || reading.day === '?') return;
        const nextDay = reading.day + 1;
        import('@/data/fullPlan').then(mod => {
            const next = mod.fullPlan.find(p => p.day === nextDay);
            if (next) {
                router.push(`/upload?reading=${encodeURIComponent(next.reading)}`);
            }
        });
    };

    const handlePrevDay = () => {
        if (!reading || !reading.day || reading.day === '?') return;
        const prevDay = reading.day - 1;
        if (prevDay < 1) return;
        import('@/data/fullPlan').then(mod => {
            const prev = mod.fullPlan.find(p => p.day === prevDay);
            if (prev) {
                router.push(`/upload?reading=${encodeURIComponent(prev.reading)}`);
            }
        });
    };

    const handleFileChange = (e) => {
        const file = e.target.files[0];
        if (file) {
            setSelectedFile(file); // Save raw file
            const reader = new FileReader();
            reader.onload = (e) => setSelectedImage(e.target.result);
            reader.readAsDataURL(file);
        }
    };

    const handlePost = async () => {
        if (!selectedFile || !user) return;
        setUploading(true);

        try {
            // 1. Compress Image
            const compressedBlob = await compressImage(selectedFile, { quality: 0.6, maxWidth: 1024 });
            const fileExt = 'jpg';
            const fileName = `${user.id}/${Date.now()}.${fileExt}`;

            // 2. Upload to Supabase Storage
            const { error: uploadError } = await supabase.storage
                .from('proofs')
                .upload(fileName, compressedBlob, {
                    contentType: 'image/jpeg',
                    upsert: false
                });

            if (uploadError) throw uploadError;

            // 3. Get Public URL
            const { data: { publicUrl } } = supabase.storage
                .from('proofs')
                .getPublicUrl(fileName);

            // 4. Save Post to DB
            const { error: dbError } = await supabase
                .from('posts')
                .insert([
                    {
                        user_id: user.id,
                        reading_ref: reading.reading, // Store the string, not the object
                        image_url: publicUrl,
                        caption: caption
                    }
                ]);

            if (dbError) throw dbError;

            // Success!
            router.push('/');
        } catch (error) {
            console.error('Error uploading:', error);
            alert('Upload failed: ' + error.message);
        } finally {
            setUploading(false);
        }
    };

    if (!reading) return <Layout><div style={{ padding: 20 }}>Loading...</div></Layout>;

    return (
        <Layout title="Upload Proof">
            <div style={{ marginBottom: '20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <Button variant="ghost" onClick={() => router.push('/calendar')}>← Back to Calendar</Button>
                <div style={{ display: 'flex', gap: '8px' }}>
                    <Button variant="ghost" style={{ padding: '8px' }} onClick={handlePrevDay}>← Prev</Button>
                    <Button variant="ghost" style={{ padding: '8px' }} onClick={handleNextDay}>Next →</Button>
                </div>
            </div>

            <h1 className="text-gradient" style={{ fontSize: '1.8rem', marginBottom: '24px' }}>Capture Reading</h1>

            <Card>
                <div style={{ marginBottom: '16px', color: 'var(--text-muted)' }}>
                    Day {reading.day} • {(() => {
                        const [y, m, d] = reading.date.split('-').map(Number);
                        return new Date(y, m - 1, d).toLocaleDateString(undefined, {
                            weekday: 'long',
                            year: 'numeric',
                            month: 'long',
                            day: 'numeric'
                        });
                    })()}
                </div>
                <div style={{ fontSize: '1.4rem', fontWeight: 'bold' }}>{reading.reading}</div>
            </Card>

            <div
                onClick={() => fileInputRef.current?.click()}
                style={{
                    border: '2px dashed var(--glass-border)',
                    borderRadius: 'var(--radius-md)',
                    height: '300px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    marginBottom: '24px',
                    cursor: 'pointer',
                    background: selectedImage ? `url(${selectedImage}) center/cover no-repeat` : 'var(--glass-bg)',
                    position: 'relative',
                    overflow: 'hidden'
                }}
            >
                {!selectedImage && (
                    <div style={{ textAlign: 'center', color: 'var(--text-muted)' }}>
                        <div style={{ fontSize: '2rem', marginBottom: '8px' }}>📷</div>
                        <div>Tap to take photo</div>
                    </div>
                )}
                <input
                    type="file"
                    accept="image/*"
                    capture="environment"
                    ref={fileInputRef}
                    onChange={handleFileChange}
                    style={{ display: 'none' }}
                />
            </div>

            <textarea
                placeholder="Add a thought or prayer... (optional)"
                value={caption}
                onChange={(e) => setCaption(e.target.value)}
                style={{
                    width: '100%',
                    padding: '16px',
                    background: 'var(--bg-color-alt)',
                    border: '1px solid var(--glass-border)',
                    borderRadius: 'var(--radius-sm)',
                    color: 'var(--text-main)',
                    minHeight: '100px',
                    marginBottom: '24px',
                    resize: 'none',
                    fontFamily: 'inherit'
                }}
            />

            <Button
                variant="primary"
                style={{ width: '100%' }}
                onClick={handlePost}
                disabled={!selectedImage || uploading}
            >
                {isSubmitting ? 'Posting...' : 'Post Update'}
            </Button>
        </Layout>
    );
}
