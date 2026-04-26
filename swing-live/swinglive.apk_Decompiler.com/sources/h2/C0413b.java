package h2;

import X1.g;
import X1.h;
import X1.i;
import a.AbstractC0184a;
import g2.f;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;

/* JADX INFO: renamed from: h2.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0413b extends AbstractC0412a {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final int f4415f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final int f4416g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final ArrayList f4417h;

    public C0413b(String str, int i4, int i5, int i6, f fVar) {
        super(str, i4, i5, i6, fVar);
        this.f4415f = i5;
        this.f4416g = i6;
        ArrayList arrayList = new ArrayList();
        this.f4417h = arrayList;
        i iVar = new i(str);
        arrayList.add(iVar);
        int i7 = iVar.f2398b + 1 + this.e;
        g gVar = new g(i4);
        this.e = i7 + 9;
        arrayList.add(gVar);
    }

    @Override // g2.o
    public final g2.g c() {
        return g2.g.f4351u;
    }

    @Override // g2.o
    public final void d(InputStream inputStream) throws IOException {
        J3.i.e(inputStream, "input");
        ArrayList arrayList = this.f4417h;
        arrayList.clear();
        int iA = 0;
        while (iA < a().f4373c) {
            X1.b bVarG = AbstractC0184a.G(inputStream);
            iA += bVarG.a() + 1;
            arrayList.add(bVarG);
        }
        if (!arrayList.isEmpty()) {
            if (arrayList.get(0) instanceof i) {
                Object obj = arrayList.get(0);
                J3.i.c(obj, "null cannot be cast to non-null type com.pedro.rtmp.amf.v0.AmfString");
                String str = ((i) obj).f2397a;
                J3.i.e(str, "<set-?>");
                this.f4413c = str;
            }
            if (arrayList.size() >= 2 && (arrayList.get(1) instanceof g)) {
                Object obj2 = arrayList.get(1);
                J3.i.c(obj2, "null cannot be cast to non-null type com.pedro.rtmp.amf.v0.AmfNumber");
                this.f4414d = (int) ((g) obj2).f2394a;
            }
        }
        this.e = iA;
        a().f4373c = this.e;
    }

    @Override // g2.o
    public final byte[] e() throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        for (X1.b bVar : this.f4417h) {
            bVar.e(byteArrayOutputStream);
            bVar.d(byteArrayOutputStream);
        }
        byte[] byteArray = byteArrayOutputStream.toByteArray();
        J3.i.d(byteArray, "toByteArray(...)");
        return byteArray;
    }

    @Override // h2.AbstractC0412a
    public final String h() {
        Object obj = this.f4417h.get(3);
        J3.i.c(obj, "null cannot be cast to non-null type com.pedro.rtmp.amf.v0.AmfObject");
        X1.b bVarF = ((h) obj).f("code");
        J3.i.c(bVarF, "null cannot be cast to non-null type com.pedro.rtmp.amf.v0.AmfString");
        return ((i) bVarF).f2397a;
    }

    @Override // h2.AbstractC0412a
    public final String i() {
        Object obj = this.f4417h.get(3);
        J3.i.c(obj, "null cannot be cast to non-null type com.pedro.rtmp.amf.v0.AmfObject");
        X1.b bVarF = ((h) obj).f("description");
        J3.i.c(bVarF, "null cannot be cast to non-null type com.pedro.rtmp.amf.v0.AmfString");
        return ((i) bVarF).f2397a;
    }

    @Override // h2.AbstractC0412a
    public final int j() {
        Object obj = this.f4417h.get(3);
        J3.i.c(obj, "null cannot be cast to non-null type com.pedro.rtmp.amf.v0.AmfNumber");
        return (int) ((g) obj).f2394a;
    }

    public final void k(X1.b bVar) {
        this.f4417h.add(bVar);
        this.e = bVar.a() + 1 + this.e;
        a().f4373c = this.e;
    }

    public final String toString() {
        String str = this.f4413c;
        int i4 = this.f4414d;
        ArrayList arrayList = this.f4417h;
        int i5 = this.e;
        StringBuilder sb = new StringBuilder("Command(name='");
        sb.append(str);
        sb.append("', transactionId=");
        sb.append(i4);
        sb.append(", timeStamp=");
        sb.append(this.f4415f);
        sb.append(", streamId=");
        sb.append(this.f4416g);
        sb.append(", data=");
        sb.append(arrayList);
        sb.append(", bodySize=");
        return B1.a.n(sb, i5, ")");
    }
}
