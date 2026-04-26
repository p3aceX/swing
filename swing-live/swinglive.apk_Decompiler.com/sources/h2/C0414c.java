package h2;

import J3.i;
import K.k;
import Y1.d;
import Y1.e;
import Y1.g;
import Y1.h;
import f2.EnumC0401a;
import f2.EnumC0402b;
import g2.f;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.LinkedHashMap;

/* JADX INFO: renamed from: h2.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0414c extends AbstractC0412a {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final ArrayList f4418f;

    /* JADX WARN: Illegal instructions before constructor call */
    public C0414c() {
        EnumC0402b enumC0402b = EnumC0402b.f4286b;
        EnumC0401a[] enumC0401aArr = EnumC0401a.f4285a;
        super("", 0, 0, 0, new f(enumC0402b, 3));
        ArrayList arrayList = new ArrayList();
        this.f4418f = arrayList;
        g gVar = new g();
        gVar.f2507a = "";
        arrayList.add(gVar);
        gVar.a();
        throw null;
    }

    @Override // g2.o
    public final g2.g c() {
        return g2.g.f4348r;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r3v10, types: [Y1.e] */
    /* JADX WARN: Type inference failed for: r3v11, types: [Y1.e] */
    /* JADX WARN: Type inference failed for: r3v12, types: [Y1.e] */
    /* JADX WARN: Type inference failed for: r3v13, types: [Y1.d, java.lang.Object] */
    /* JADX WARN: Type inference failed for: r3v14, types: [Y1.g, java.lang.Object] */
    /* JADX WARN: Type inference failed for: r3v4, types: [Y1.a] */
    /* JADX WARN: Type inference failed for: r3v5, types: [Y1.b, java.lang.Object] */
    /* JADX WARN: Type inference failed for: r3v6, types: [Y1.f] */
    /* JADX WARN: Type inference failed for: r3v7, types: [Y1.f] */
    /* JADX WARN: Type inference failed for: r3v8, types: [Y1.e] */
    /* JADX WARN: Type inference failed for: r3v9, types: [Y1.e] */
    @Override // g2.o
    public final void d(InputStream inputStream) throws IOException {
        Object next;
        ?? aVar;
        i.e(inputStream, "input");
        ArrayList arrayList = this.f4418f;
        arrayList.clear();
        int iA = 0;
        while (iA < a().f4373c) {
            int i4 = inputStream.read();
            B3.b bVar = h.f2518s;
            bVar.getClass();
            J3.a aVar2 = new J3.a(bVar);
            while (true) {
                if (aVar2.hasNext()) {
                    next = aVar2.next();
                    if (((h) next).f2519a == i4) {
                    }
                } else {
                    next = null;
                }
            }
            h hVar = (h) next;
            if (hVar == null) {
                hVar = h.f2513n;
            }
            int iOrdinal = hVar.ordinal();
            if (iOrdinal == 9) {
                aVar = new Y1.a();
            } else if (iOrdinal == 10) {
                aVar = new Y1.f(new LinkedHashMap());
            } else if (iOrdinal != 17) {
                switch (iOrdinal) {
                    case 0:
                        aVar = new e(4);
                        break;
                    case 1:
                        aVar = new e(2);
                        break;
                    case 2:
                        aVar = new e(3);
                        break;
                    case 3:
                        aVar = new e(0);
                        break;
                    case 4:
                        aVar = new e(1);
                        break;
                    case 5:
                        aVar = new d();
                        aVar.f2504a = 0.0d;
                        break;
                    case k.STRING_SET_FIELD_NUMBER /* 6 */:
                        aVar = new g();
                        aVar.f2507a = "";
                        break;
                    default:
                        throw new IOException(B1.a.m("Unimplemented AMF3 data type: ", hVar.name()));
                }
            } else {
                aVar = new Y1.c(new LinkedHashMap());
            }
            aVar.c(inputStream);
            iA += aVar.a() + 1;
            arrayList.add(aVar);
        }
        if (!arrayList.isEmpty()) {
            if (arrayList.get(0) instanceof g) {
                Object obj = arrayList.get(0);
                i.c(obj, "null cannot be cast to non-null type com.pedro.rtmp.amf.v3.Amf3String");
                String str = ((g) obj).f2507a;
                i.e(str, "<set-?>");
                this.f4413c = str;
            }
            if (arrayList.size() >= 2 && (arrayList.get(1) instanceof d)) {
                Object obj2 = arrayList.get(1);
                i.c(obj2, "null cannot be cast to non-null type com.pedro.rtmp.amf.v3.Amf3Double");
                this.f4414d = (int) ((d) obj2).f2504a;
            }
        }
        this.e = iA;
        a().f4373c = this.e;
    }

    @Override // g2.o
    public final byte[] e() throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        for (Y1.b bVar : this.f4418f) {
            byteArrayOutputStream.write(bVar.b().f2519a);
            bVar.d(byteArrayOutputStream);
        }
        byte[] byteArray = byteArrayOutputStream.toByteArray();
        i.d(byteArray, "toByteArray(...)");
        return byteArray;
    }

    @Override // h2.AbstractC0412a
    public final String h() {
        Object obj = this.f4418f.get(3);
        i.c(obj, "null cannot be cast to non-null type com.pedro.rtmp.amf.v3.Amf3Object");
        Y1.b bVarE = ((Y1.f) obj).e("code");
        i.c(bVarE, "null cannot be cast to non-null type com.pedro.rtmp.amf.v3.Amf3String");
        return ((g) bVarE).f2507a;
    }

    @Override // h2.AbstractC0412a
    public final String i() {
        Object obj = this.f4418f.get(3);
        i.c(obj, "null cannot be cast to non-null type com.pedro.rtmp.amf.v3.Amf3Object");
        Y1.b bVarE = ((Y1.f) obj).e("description");
        i.c(bVarE, "null cannot be cast to non-null type com.pedro.rtmp.amf.v3.Amf3String");
        return ((g) bVarE).f2507a;
    }

    @Override // h2.AbstractC0412a
    public final int j() {
        Object obj = this.f4418f.get(3);
        i.c(obj, "null cannot be cast to non-null type com.pedro.rtmp.amf.v3.Amf3Double");
        return (int) ((d) obj).f2504a;
    }

    public final String toString() {
        return "Command(name='" + this.f4413c + "', transactionId=" + this.f4414d + ", timeStamp=0, streamId=0, data=" + this.f4418f + ", bodySize=" + this.e + ")";
    }
}
