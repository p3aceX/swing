package M;

import java.io.IOException;
import java.io.InputStream;

/* JADX INFO: loaded from: classes.dex */
public final class f extends b {
    public f(byte[] bArr) {
        super(bArr);
        this.f890a.mark(com.google.android.gms.common.api.f.API_PRIORITY_OTHER);
    }

    public final void b(long j4) throws IOException {
        int i4 = this.f891b;
        if (i4 > j4) {
            this.f891b = 0;
            this.f890a.reset();
        } else {
            j4 -= (long) i4;
        }
        a((int) j4);
    }

    public f(InputStream inputStream) {
        super(inputStream);
        if (inputStream.markSupported()) {
            this.f890a.mark(com.google.android.gms.common.api.f.API_PRIORITY_OTHER);
            return;
        }
        throw new IllegalArgumentException("Cannot create SeekableByteOrderedDataInputStream with stream that does not support mark/reset");
    }
}
