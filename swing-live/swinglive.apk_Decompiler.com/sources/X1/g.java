package X1;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import y1.AbstractC0752b;

/* JADX INFO: loaded from: classes.dex */
public final class g extends b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public double f2394a;

    public g(double d5) {
        this.f2394a = d5;
    }

    @Override // X1.b
    public final int a() {
        return 8;
    }

    @Override // X1.b
    public final j b() {
        return j.f2399b;
    }

    @Override // X1.b
    public final void c(InputStream inputStream) throws IOException {
        J3.i.e(inputStream, "input");
        byte[] bArr = new byte[8];
        AbstractC0752b.i(inputStream, bArr);
        this.f2394a = Double.longBitsToDouble(ByteBuffer.wrap(bArr).getLong());
    }

    @Override // X1.b
    public final void d(ByteArrayOutputStream byteArrayOutputStream) throws IOException {
        byteArrayOutputStream.write(ByteBuffer.allocate(8).putLong(Double.doubleToRawLongBits(this.f2394a)).array());
    }

    public final String toString() {
        return "AmfNumber value: " + this.f2394a;
    }
}
