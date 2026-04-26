package s2;

import J3.i;
import com.google.android.gms.common.api.f;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Arrays;
import o3.C0592H;
import w2.EnumC0703a;
import y1.AbstractC0752b;

/* JADX INFO: loaded from: classes.dex */
public final class b extends Q.b {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f6482b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final w2.b f6483c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final EnumC0703a f6484d;
    public boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f6485f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final int f6486g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final int f6487h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final byte[] f6488i;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public b(int i4, int i5, int i6, int i7, byte[] bArr, int i8) {
        super(3);
        EnumC0703a enumC0703a = EnumC0703a.f6710b;
        w2.b bVar = w2.b.f6713b;
        i4 = (i8 & 1) != 0 ? 0 : i4;
        i5 = (i8 & 32) != 0 ? 0 : i5;
        i6 = (i8 & 64) != 0 ? 0 : i6;
        i7 = (i8 & 128) != 0 ? 0 : i7;
        bArr = (i8 & 256) != 0 ? new byte[0] : bArr;
        i.e(bArr, "payload");
        this.f6482b = i4;
        this.f6483c = bVar;
        this.f6484d = enumC0703a;
        this.e = false;
        this.f6485f = i5;
        this.f6486g = i6;
        this.f6487h = i7;
        this.f6488i = bArr;
    }

    public final void k() throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        this.f1509a = byteArrayOutputStream;
        C0592H c0592h = c.f6489b;
        int i4 = this.f6482b & f.API_PRIORITY_OTHER;
        int i5 = (this.f6483c.f6715a << 30) | (this.f6484d.f6712a << 27) | ((this.e ? 1 : 0) << 26) | this.f6485f;
        AbstractC0752b.s(byteArrayOutputStream, i4);
        AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, i5);
        AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, this.f6486g);
        AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, this.f6487h);
        ((ByteArrayOutputStream) this.f1509a).write(this.f6488i);
    }

    public final String toString() {
        boolean z4 = this.e;
        int i4 = this.f6485f;
        String string = Arrays.toString(this.f6488i);
        i.d(string, "toString(...)");
        return "DataPacket(sequenceNumber=" + this.f6482b + ", packetPosition=" + this.f6483c + ", order=false, encryption=" + this.f6484d + ", retransmitted=" + z4 + ", messageNumber=" + i4 + ", ts=" + this.f6486g + ", socketId=" + this.f6487h + ", payload=" + string + ")";
    }
}
