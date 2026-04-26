package Y1;

import J3.i;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import y1.AbstractC0752b;

/* JADX INFO: loaded from: classes.dex */
public final class d extends b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public double f2504a;

    @Override // Y1.b
    public final int a() {
        return 8;
    }

    @Override // Y1.b
    public final h b() {
        return h.f2512m;
    }

    @Override // Y1.b
    public final void c(InputStream inputStream) throws IOException {
        i.e(inputStream, "input");
        byte[] bArr = new byte[8];
        AbstractC0752b.i(inputStream, bArr);
        this.f2504a = Double.longBitsToDouble(ByteBuffer.wrap(bArr).getLong());
    }

    @Override // Y1.b
    public final void d(ByteArrayOutputStream byteArrayOutputStream) throws IOException {
        byteArrayOutputStream.write(ByteBuffer.allocate(8).putLong(Double.doubleToRawLongBits(this.f2504a)).array());
    }
}
