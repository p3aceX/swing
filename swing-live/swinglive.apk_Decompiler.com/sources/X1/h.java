package X1;

import a.AbstractC0184a;
import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Map;
import y1.AbstractC0752b;

/* JADX INFO: loaded from: classes.dex */
public class h extends b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final LinkedHashMap f2395a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2396b;

    public h(LinkedHashMap linkedHashMap) {
        this.f2395a = linkedHashMap;
        for (Map.Entry entry : linkedHashMap.entrySet()) {
            int i4 = this.f2396b + ((i) entry.getKey()).f2398b;
            this.f2396b = i4;
            this.f2396b = ((b) entry.getValue()).a() + 1 + i4;
        }
        j jVar = j.f2399b;
        this.f2396b += 3;
    }

    @Override // X1.b
    public final int a() {
        return this.f2396b;
    }

    @Override // X1.b
    public j b() {
        return j.e;
    }

    @Override // X1.b
    public void c(InputStream inputStream) throws IOException {
        J3.i.e(inputStream, "input");
        LinkedHashMap linkedHashMap = this.f2395a;
        linkedHashMap.clear();
        boolean zEquals = false;
        this.f2396b = 0;
        j jVar = j.f2399b;
        byte[] bArr = {0, 0, 9};
        InputStream bufferedInputStream = inputStream.markSupported() ? inputStream : new BufferedInputStream(inputStream);
        while (!zEquals) {
            bufferedInputStream.mark(3);
            byte[] bArr2 = new byte[3];
            AbstractC0752b.i(inputStream, bArr2);
            zEquals = Arrays.equals(bArr2, bArr);
            if (zEquals) {
                this.f2396b += 3;
            } else {
                bufferedInputStream.reset();
                i iVar = new i();
                iVar.c(inputStream);
                this.f2396b += iVar.f2398b;
                b bVarG = AbstractC0184a.G(inputStream);
                this.f2396b = bVarG.a() + 1 + this.f2396b;
                linkedHashMap.put(iVar, bVarG);
            }
        }
    }

    @Override // X1.b
    public void d(ByteArrayOutputStream byteArrayOutputStream) throws IOException {
        for (Map.Entry entry : this.f2395a.entrySet()) {
            ((i) entry.getKey()).d(byteArrayOutputStream);
            ((b) entry.getValue()).e(byteArrayOutputStream);
            ((b) entry.getValue()).d(byteArrayOutputStream);
        }
        j jVar = j.f2399b;
        byteArrayOutputStream.write(new byte[]{0, 0, 9});
    }

    public final b f(String str) {
        for (Map.Entry entry : this.f2395a.entrySet()) {
            if (J3.i.a(((i) entry.getKey()).f2397a, str)) {
                return (b) entry.getValue();
            }
        }
        return null;
    }

    public void g(String str, double d5) {
        i iVar = new i(str);
        this.f2395a.put(iVar, new g(d5));
        this.f2396b = this.f2396b + iVar.f2398b + 9;
    }

    public void h(String str, String str2) {
        J3.i.e(str2, "data");
        i iVar = new i(str);
        i iVar2 = new i(str2);
        this.f2395a.put(iVar, iVar2);
        this.f2396b = iVar2.f2398b + 1 + this.f2396b + iVar.f2398b;
    }

    public String toString() {
        return "AmfObject properties: " + this.f2395a;
    }

    public /* synthetic */ h() {
        this(new LinkedHashMap());
    }
}
