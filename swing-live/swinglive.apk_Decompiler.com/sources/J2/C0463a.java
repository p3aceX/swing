package j2;

import B3.b;
import J3.i;
import X1.j;
import Y1.h;
import a.AbstractC0184a;
import f2.EnumC0401a;
import f2.EnumC0402b;
import g2.f;
import g2.g;
import g2.o;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Iterator;
import y1.AbstractC0752b;

/* JADX INFO: renamed from: j2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0463a extends o {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5220c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ int f5221d;
    public String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final ArrayList f5222f;

    public C0463a(int i4, int i5, f fVar) {
        super(fVar);
        a().f4373c = this.f5220c;
        a().f4372b = i4;
        a().e = i5;
    }

    @Override // g2.o
    public final int b() {
        return this.f5220c;
    }

    @Override // g2.o
    public final g c() {
        switch (this.f5221d) {
            case 0:
                return g.f4349s;
            default:
                return g.f4346p;
        }
    }

    @Override // g2.o
    public final void d(InputStream inputStream) throws IOException {
        Object obj = null;
        ArrayList arrayList = this.f5222f;
        int i4 = this.f5221d;
        i.e(inputStream, "input");
        switch (i4) {
            case 0:
                arrayList.clear();
                this.f5220c = 0;
                i.d("".getBytes(P3.a.f1492a), "getBytes(...)");
                int i5 = inputStream.read();
                b bVar = j.f2411u;
                bVar.getClass();
                J3.a aVar = new J3.a(bVar);
                while (true) {
                    if (aVar.hasNext()) {
                        Object next = aVar.next();
                        if (((j) next).f2412a == i5) {
                            obj = next;
                        }
                    }
                }
                if (((j) obj) == null) {
                    j jVar = j.f2399b;
                }
                int iG = AbstractC0752b.g(inputStream);
                byte[] bArr = new byte[iG];
                AbstractC0752b.i(inputStream, bArr);
                this.e = new String(bArr, P3.a.f1492a);
                this.f5220c = iG + 3 + this.f5220c;
                while (this.f5220c < a().f4373c) {
                    X1.b bVarG = AbstractC0184a.G(inputStream);
                    arrayList.add(bVarG);
                    this.f5220c = bVarG.a() + 1 + this.f5220c;
                }
                return;
            default:
                arrayList.clear();
                this.f5220c = 0;
                int i6 = inputStream.read();
                b bVar2 = h.f2518s;
                bVar2.getClass();
                J3.a aVar2 = new J3.a(bVar2);
                while (true) {
                    if (aVar2.hasNext()) {
                        Object next2 = aVar2.next();
                        if (((h) next2).f2519a == i6) {
                            obj = next2;
                        }
                    }
                }
                if (((h) obj) == null) {
                    h hVar = h.f2508b;
                }
                throw new H3.a();
        }
    }

    @Override // g2.o
    public final byte[] e() throws IOException {
        switch (this.f5221d) {
            case 0:
                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                String str = this.e;
                i.e(str, "value");
                Charset charset = P3.a.f1492a;
                byte[] bytes = str.getBytes(charset);
                i.d(bytes, "getBytes(...)");
                int length = bytes.length;
                j jVar = j.f2399b;
                byteArrayOutputStream.write(2);
                AbstractC0752b.r(byteArrayOutputStream, length);
                byte[] bytes2 = str.getBytes(charset);
                i.d(bytes2, "getBytes(...)");
                byteArrayOutputStream.write(bytes2);
                for (X1.b bVar : this.f5222f) {
                    bVar.e(byteArrayOutputStream);
                    bVar.d(byteArrayOutputStream);
                }
                byte[] byteArray = byteArrayOutputStream.toByteArray();
                i.d(byteArray, "toByteArray(...)");
                return byteArray;
            default:
                ByteArrayOutputStream byteArrayOutputStream2 = new ByteArrayOutputStream();
                i.e(this.e, "value");
                h hVar = h.f2508b;
                byteArrayOutputStream2.write(6);
                throw new H3.a();
        }
    }

    public void h(X1.b bVar) {
        this.f5222f.add(bVar);
        this.f5220c = bVar.a() + 1 + this.f5220c;
        a().f4373c = this.f5220c;
    }

    public final String toString() {
        switch (this.f5221d) {
            case 0:
                String str = this.e;
                ArrayList arrayList = this.f5222f;
                int i4 = this.f5220c;
                StringBuilder sb = new StringBuilder("Data(name='");
                sb.append(str);
                sb.append("', data=");
                sb.append(arrayList);
                sb.append(", bodySize=");
                return B1.a.n(sb, i4, ")");
            default:
                ArrayList arrayList2 = this.f5222f;
                int i5 = this.f5220c;
                StringBuilder sb2 = new StringBuilder("Data(name='");
                sb2.append(this.e);
                sb2.append("', data=");
                sb2.append(arrayList2);
                sb2.append(", bodySize=");
                return B1.a.n(sb2, i5, ")");
        }
    }

    /* JADX WARN: Illegal instructions before constructor call */
    public C0463a() {
        this.f5221d = 1;
        EnumC0402b enumC0402b = EnumC0402b.f4286b;
        EnumC0401a[] enumC0401aArr = EnumC0401a.f4285a;
        this(0, 0, new f(enumC0402b, 3));
        this.e = "";
        this.f5222f = new ArrayList();
        throw new H3.a();
    }

    /* JADX WARN: Illegal instructions before constructor call */
    public C0463a(int i4, int i5, int i6) {
        this.f5221d = 0;
        String str = (i6 & 1) != 0 ? "" : "@setDataFrame";
        i4 = (i6 & 2) != 0 ? 0 : i4;
        i5 = (i6 & 4) != 0 ? 0 : i5;
        EnumC0402b enumC0402b = EnumC0402b.f4286b;
        EnumC0401a[] enumC0401aArr = EnumC0401a.f4285a;
        this(i4, i5, new f(enumC0402b, 3));
        this.e = str;
        ArrayList arrayList = new ArrayList();
        this.f5222f = arrayList;
        String str2 = this.e;
        i.e(str2, "value");
        byte[] bytes = str2.getBytes(P3.a.f1492a);
        i.d(bytes, "getBytes(...)");
        this.f5220c = bytes.length + 3 + this.f5220c;
        Iterator it = arrayList.iterator();
        while (it.hasNext()) {
            this.f5220c = ((X1.b) it.next()).a() + 1 + this.f5220c;
        }
    }
}
