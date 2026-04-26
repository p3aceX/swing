package M;

import android.media.MediaDataSource;
import java.io.IOException;

/* JADX INFO: loaded from: classes.dex */
public final class a extends MediaDataSource {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public long f888a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ f f889b;

    public a(f fVar) {
        this.f889b = fVar;
    }

    @Override // android.media.MediaDataSource
    public final long getSize() {
        return -1L;
    }

    @Override // android.media.MediaDataSource
    public final int readAt(long j4, byte[] bArr, int i4, int i5) {
        if (i5 == 0) {
            return 0;
        }
        if (j4 < 0) {
            return -1;
        }
        try {
            long j5 = this.f888a;
            f fVar = this.f889b;
            if (j5 != j4) {
                if (j5 >= 0 && j4 >= j5 + ((long) fVar.f890a.available())) {
                    return -1;
                }
                fVar.b(j4);
                this.f888a = j4;
            }
            if (i5 > fVar.f890a.available()) {
                i5 = fVar.f890a.available();
            }
            int i6 = fVar.read(bArr, i4, i5);
            if (i6 >= 0) {
                this.f888a += (long) i6;
                return i6;
            }
        } catch (IOException unused) {
        }
        this.f888a = -1L;
        return -1;
    }

    @Override // java.io.Closeable, java.lang.AutoCloseable
    public final void close() {
    }
}
