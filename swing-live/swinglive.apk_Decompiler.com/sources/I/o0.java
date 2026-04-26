package I;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

/* JADX INFO: loaded from: classes.dex */
public final class o0 extends OutputStream {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final FileOutputStream f712a;

    public o0(FileOutputStream fileOutputStream) {
        this.f712a = fileOutputStream;
    }

    @Override // java.io.OutputStream, java.io.Flushable
    public final void flush() throws IOException {
        this.f712a.flush();
    }

    @Override // java.io.OutputStream
    public final void write(int i4) throws IOException {
        this.f712a.write(i4);
    }

    @Override // java.io.OutputStream
    public final void write(byte[] bArr) throws IOException {
        J3.i.e(bArr, "b");
        this.f712a.write(bArr);
    }

    @Override // java.io.OutputStream
    public final void write(byte[] bArr, int i4, int i5) throws IOException {
        J3.i.e(bArr, "bytes");
        this.f712a.write(bArr, i4, i5);
    }

    @Override // java.io.OutputStream, java.io.Closeable, java.lang.AutoCloseable
    public final void close() {
    }
}
