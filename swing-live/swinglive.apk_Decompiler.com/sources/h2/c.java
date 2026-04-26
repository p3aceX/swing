package H2;

import android.media.MediaDataSource;

/* JADX INFO: loaded from: classes.dex */
public final class c extends MediaDataSource {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ byte[] f528a;

    public c(byte[] bArr) {
        this.f528a = bArr;
    }

    @Override // android.media.MediaDataSource
    public final long getSize() {
        return this.f528a.length;
    }

    @Override // android.media.MediaDataSource
    public final int readAt(long j4, byte[] bArr, int i4, int i5) {
        byte[] bArr2 = this.f528a;
        if (j4 >= bArr2.length) {
            return -1;
        }
        if (((long) i5) + j4 > bArr2.length) {
            i5 = (int) (((long) bArr2.length) - j4);
        }
        System.arraycopy(bArr2, (int) j4, bArr, i4, i5);
        return i5;
    }

    @Override // java.io.Closeable, java.lang.AutoCloseable
    public final void close() {
    }
}
