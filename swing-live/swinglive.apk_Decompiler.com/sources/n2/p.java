package N2;

import com.google.crypto.tink.shaded.protobuf.S;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public final class p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f1194a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f1195b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f1196c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f1197d;
    public final int e;

    public p(String str, int i4, int i5, int i6, int i7) {
        if (!(i4 == -1 && i5 == -1) && (i4 < 0 || i5 < 0)) {
            throw new IndexOutOfBoundsException("invalid selection: (" + i4 + ", " + i5 + ")");
        }
        if (!(i6 == -1 && i7 == -1) && (i6 < 0 || i6 > i7)) {
            throw new IndexOutOfBoundsException("invalid composing range: (" + i6 + ", " + i7 + ")");
        }
        if (i7 > str.length()) {
            throw new IndexOutOfBoundsException(S.d(i6, "invalid composing start: "));
        }
        if (i4 > str.length()) {
            throw new IndexOutOfBoundsException(S.d(i4, "invalid selection start: "));
        }
        if (i5 > str.length()) {
            throw new IndexOutOfBoundsException(S.d(i5, "invalid selection end: "));
        }
        this.f1194a = str;
        this.f1195b = i4;
        this.f1196c = i5;
        this.f1197d = i6;
        this.e = i7;
    }

    public static p a(JSONObject jSONObject) {
        return new p(jSONObject.getString("text"), jSONObject.getInt("selectionBase"), jSONObject.getInt("selectionExtent"), jSONObject.getInt("composingBase"), jSONObject.getInt("composingExtent"));
    }
}
