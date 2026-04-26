package F3;

import J3.i;
import java.io.ByteArrayOutputStream;

/* JADX INFO: loaded from: classes.dex */
public final class a extends ByteArrayOutputStream {
    public byte[] a() {
        return ((ByteArrayOutputStream) this).buf;
    }

    public byte[] b() {
        byte[] bArr = ((ByteArrayOutputStream) this).buf;
        i.d(bArr, "buf");
        return bArr;
    }
}
