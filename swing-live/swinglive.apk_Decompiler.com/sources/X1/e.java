package X1;

import a.AbstractC0184a;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import y1.AbstractC0752b;

/* JADX INFO: loaded from: classes.dex */
public class e extends b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f2390a = 0;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2391b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Serializable f2392c;

    public e(String str) {
        this.f2392c = str;
        byte[] bytes = str.getBytes(P3.a.f1492a);
        J3.i.d(bytes, "getBytes(...)");
        this.f2391b = bytes.length + 4;
    }

    @Override // X1.b
    public final int a() {
        switch (this.f2390a) {
        }
        return this.f2391b;
    }

    @Override // X1.b
    public j b() {
        switch (this.f2390a) {
            case 0:
                return j.f2407q;
            default:
                return j.f2405o;
        }
    }

    @Override // X1.b
    public final void c(InputStream inputStream) throws IOException {
        switch (this.f2390a) {
            case 0:
                J3.i.e(inputStream, "input");
                int iH = AbstractC0752b.h(inputStream);
                this.f2391b = iH;
                byte[] bArr = new byte[iH];
                this.f2391b = iH + 4;
                AbstractC0752b.i(inputStream, bArr);
                this.f2392c = new String(bArr, P3.a.f1492a);
                break;
            default:
                J3.i.e(inputStream, "input");
                ArrayList arrayList = (ArrayList) this.f2392c;
                arrayList.clear();
                this.f2391b = 0;
                int iH2 = AbstractC0752b.h(inputStream);
                this.f2391b += 4;
                for (int i4 = 0; i4 < iH2; i4++) {
                    b bVarG = AbstractC0184a.G(inputStream);
                    this.f2391b = bVarG.a() + 1 + this.f2391b;
                    arrayList.add(bVarG);
                }
                break;
        }
    }

    @Override // X1.b
    public final void d(ByteArrayOutputStream byteArrayOutputStream) throws IOException {
        switch (this.f2390a) {
            case 0:
                byte[] bytes = ((String) this.f2392c).getBytes(P3.a.f1492a);
                J3.i.d(bytes, "getBytes(...)");
                AbstractC0752b.s(byteArrayOutputStream, this.f2391b - 4);
                byteArrayOutputStream.write(bytes);
                break;
            default:
                ArrayList<b> arrayList = (ArrayList) this.f2392c;
                AbstractC0752b.s(byteArrayOutputStream, arrayList.size());
                for (b bVar : arrayList) {
                    bVar.e(byteArrayOutputStream);
                    bVar.d(byteArrayOutputStream);
                }
                break;
        }
    }

    public String toString() {
        switch (this.f2390a) {
            case 0:
                return B1.a.m("AmfLongString value: ", (String) this.f2392c);
            default:
                String string = Arrays.toString(((ArrayList) this.f2392c).toArray(new b[0]));
                J3.i.d(string, "toString(...)");
                return "AmfStrictArray items: ".concat(string);
        }
    }

    public e(ArrayList arrayList) {
        this.f2392c = arrayList;
        this.f2391b += 4;
        Iterator it = arrayList.iterator();
        while (it.hasNext()) {
            this.f2391b = ((b) it.next()).a() + 1 + this.f2391b;
        }
    }
}
