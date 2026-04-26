package u2;

import J3.i;
import P3.m;
import com.google.android.gms.common.api.f;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.InetAddress;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import o3.C0592H;
import s2.AbstractC0664a;
import t2.EnumC0679d;
import x3.AbstractC0726f;
import x3.AbstractC0728h;
import x3.AbstractC0730j;
import x3.C0727g;
import y1.AbstractC0752b;

/* JADX INFO: loaded from: classes.dex */
public final class c extends AbstractC0664a {

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public int f6649g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public EnumC0691a f6650h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public int f6651i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public int f6652j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public int f6653k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public int f6654l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public d f6655m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f6656n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f6657o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public String f6658p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final v2.c f6659q;

    /* JADX WARN: Illegal instructions before constructor call */
    public c() {
        EnumC0691a enumC0691a = EnumC0691a.f6644c;
        C0592H c0592h = b.f6647a;
        this(4, enumC0691a, 2, 0, 1500, 8192, d.f6662d, 762640158, 0, "0.0.0.0", null);
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof c)) {
            return false;
        }
        c cVar = (c) obj;
        return this.f6649g == cVar.f6649g && this.f6650h == cVar.f6650h && this.f6651i == cVar.f6651i && this.f6652j == cVar.f6652j && this.f6653k == cVar.f6653k && this.f6654l == cVar.f6654l && this.f6655m == cVar.f6655m && this.f6656n == cVar.f6656n && this.f6657o == cVar.f6657o && i.a(this.f6658p, cVar.f6658p) && i.a(this.f6659q, cVar.f6659q);
    }

    public final int hashCode() {
        int iHashCode = (this.f6658p.hashCode() + B1.a.h(this.f6657o, B1.a.h(this.f6656n, (this.f6655m.hashCode() + B1.a.h(this.f6654l, B1.a.h(this.f6653k, B1.a.h(this.f6652j, B1.a.h(this.f6651i, (this.f6650h.hashCode() + (Integer.hashCode(this.f6649g) * 31)) * 31, 31), 31), 31), 31)) * 31, 31), 31)) * 31;
        v2.c cVar = this.f6659q;
        return iHashCode + (cVar == null ? 0 : cVar.hashCode());
    }

    public final void l(int i4) throws IOException {
        byte[] bArrK;
        C0592H c0592h = s2.c.f6489b;
        AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, ((this.f6478b.f6582a & 255) << 16) | Integer.MIN_VALUE | this.f6479c.f6582a);
        AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, this.f6480d);
        AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, i4);
        AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, 0);
        AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, this.f6649g);
        AbstractC0752b.r((ByteArrayOutputStream) this.f1509a, this.f6650h.f6646a);
        AbstractC0752b.r((ByteArrayOutputStream) this.f1509a, this.f6651i);
        AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, this.f6652j & f.API_PRIORITY_OTHER);
        AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, this.f6653k);
        AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, this.f6654l);
        AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, this.f6655m.f6664a);
        AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, this.f6656n);
        AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, this.f6657o);
        byte[] address = InetAddress.getByName(this.f6658p).getAddress();
        i.d(address, "getAddress(...)");
        ArrayList arrayListN0 = AbstractC0728h.n0(AbstractC0726f.l0(address), 4, 4);
        ArrayList arrayList = new ArrayList(AbstractC0730j.V(arrayListN0));
        Iterator it = arrayListN0.iterator();
        while (it.hasNext()) {
            arrayList.add(AbstractC0728h.d0((List) it.next()));
        }
        Iterator it2 = arrayList.iterator();
        while (it2.hasNext()) {
            ((ByteArrayOutputStream) this.f1509a).write(AbstractC0728h.f0((List) it2.next()));
        }
        if (arrayList.size() == 1) {
            AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, 0);
            AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, 0);
            AbstractC0752b.s((ByteArrayOutputStream) this.f1509a, 0);
        }
        v2.c cVar = this.f6659q;
        if (cVar != null) {
            ByteArrayOutputStream byteArrayOutputStream = (ByteArrayOutputStream) cVar.f1509a;
            v2.b[] bVarArr = v2.b.f6667a;
            AbstractC0752b.r(byteArrayOutputStream, 1);
            AbstractC0752b.r((ByteArrayOutputStream) cVar.f1509a, 3);
            ByteArrayOutputStream byteArrayOutputStream2 = (ByteArrayOutputStream) cVar.f1509a;
            List listD0 = m.D0(cVar.f6668b, new String[]{"."});
            ArrayList arrayList2 = new ArrayList(AbstractC0730j.V(listD0));
            Iterator it3 = listD0.iterator();
            while (it3.hasNext()) {
                arrayList2.add(Integer.valueOf(Integer.parseInt(m.J0((String) it3.next()).toString())));
            }
            int iIntValue = ((Number) arrayList2.get(2)).intValue() + (((Number) arrayList2.get(1)).intValue() * 256) + (((Number) arrayList2.get(0)).intValue() * 65536);
            byteArrayOutputStream2.write(new byte[]{(byte) ((iIntValue >>> 24) & 255), (byte) ((iIntValue >>> 16) & 255), (byte) ((iIntValue >>> 8) & 255), (byte) (iIntValue & 255)});
            AbstractC0752b.s((ByteArrayOutputStream) cVar.f1509a, cVar.f6669c);
            AbstractC0752b.r((ByteArrayOutputStream) cVar.f1509a, cVar.f6670d);
            AbstractC0752b.r((ByteArrayOutputStream) cVar.f1509a, cVar.e);
            ByteArrayOutputStream byteArrayOutputStream3 = (ByteArrayOutputStream) cVar.f1509a;
            v2.b[] bVarArr2 = v2.b.f6667a;
            AbstractC0752b.r(byteArrayOutputStream3, 5);
            byte[] bytes = cVar.f6671f.getBytes(P3.a.f1492a);
            i.d(bytes, "getBytes(...)");
            int length = bytes.length % 4;
            if (length == 0) {
                bArrK = v2.c.k(new C0727g(bytes));
            } else {
                C0727g c0727g = new C0727g(new byte[4 - length]);
                ArrayList arrayListK0 = AbstractC0728h.k0(new C0727g(bytes));
                arrayListK0.addAll(c0727g);
                bArrK = v2.c.k(arrayListK0);
            }
            AbstractC0752b.r((ByteArrayOutputStream) cVar.f1509a, bArrK.length / 4);
            ((ByteArrayOutputStream) cVar.f1509a).write(bArrK);
            ByteArrayOutputStream byteArrayOutputStream4 = (ByteArrayOutputStream) this.f1509a;
            byte[] byteArray = ((ByteArrayOutputStream) cVar.f1509a).toByteArray();
            i.d(byteArray, "toByteArray(...)");
            byteArrayOutputStream4.write(byteArray);
        }
    }

    @Override // s2.AbstractC0664a
    public final String toString() {
        return "Handshake(handshakeVersion=" + this.f6649g + ", encryption=" + this.f6650h + ", extensionField=" + this.f6651i + ", initialPacketSequence=" + this.f6652j + ", MTU=" + this.f6653k + ", flowWindowsSize=" + this.f6654l + ", handshakeType=" + this.f6655m + ", srtSocketId=" + this.f6656n + ", synCookie=" + this.f6657o + ", ipAddress='" + this.f6658p + "', handshakeExtension=" + this.f6659q + ")";
    }

    public c(int i4, EnumC0691a enumC0691a, int i5, int i6, int i7, int i8, d dVar, int i9, int i10, String str, v2.c cVar) {
        super(EnumC0679d.f6571c, 30);
        this.f6649g = i4;
        this.f6650h = enumC0691a;
        this.f6651i = i5;
        this.f6652j = i6;
        this.f6653k = i7;
        this.f6654l = i8;
        this.f6655m = dVar;
        this.f6656n = i9;
        this.f6657o = i10;
        this.f6658p = str;
        this.f6659q = cVar;
    }
}
