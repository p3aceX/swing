package Z;

import K.j;
import K.k;
import android.content.SharedPreferences;
import com.google.crypto.tink.shaded.protobuf.S;
import e1.AbstractC0366f;
import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class b implements SharedPreferences {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final SharedPreferences f2547a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final CopyOnWriteArrayList f2548b = new CopyOnWriteArrayList();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f2549c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final R0.a f2550d;
    public final R0.c e;

    public b(String str, SharedPreferences sharedPreferences, R0.a aVar, R0.c cVar) {
        this.f2549c = str;
        this.f2547a = sharedPreferences;
        this.f2550d = aVar;
        this.e = cVar;
    }

    public static boolean c(String str) {
        return "__androidx_security_crypto_encrypted_prefs_key_keyset__".equals(str) || "__androidx_security_crypto_encrypted_prefs_value_keyset__".equals(str);
    }

    public final String a(String str) {
        if (str == null) {
            str = "__NULL__";
        }
        try {
            try {
                return new String(AbstractC0366f.b(this.e.a(str.getBytes(StandardCharsets.UTF_8), this.f2549c.getBytes())), "US-ASCII");
            } catch (UnsupportedEncodingException e) {
                throw new AssertionError(e);
            }
        } catch (GeneralSecurityException e4) {
            throw new SecurityException("Could not encrypt key. " + e4.getMessage(), e4);
        }
    }

    public final Object b(String str) {
        String str2;
        if (c(str)) {
            throw new SecurityException(S.f(str, " is a reserved key for the encryption keyset."));
        }
        if (str == null) {
            str = "__NULL__";
        }
        try {
            String strA = a(str);
            String string = this.f2547a.getString(strA, null);
            if (string != null) {
                byte[] bArrA = AbstractC0366f.a(string);
                R0.a aVar = this.f2550d;
                Charset charset = StandardCharsets.UTF_8;
                ByteBuffer byteBufferWrap = ByteBuffer.wrap(aVar.b(bArrA, strA.getBytes(charset)));
                byteBufferWrap.position(0);
                int i4 = byteBufferWrap.getInt();
                int i5 = i4 != 0 ? i4 != 1 ? i4 != 2 ? i4 != 3 ? i4 != 4 ? i4 != 5 ? 0 : 6 : 5 : 4 : 3 : 2 : 1;
                if (i5 == 0) {
                    throw new SecurityException("Unknown type ID for encrypted pref value: " + i4);
                }
                int iB = j.b(i5);
                if (iB == 0) {
                    int i6 = byteBufferWrap.getInt();
                    ByteBuffer byteBufferSlice = byteBufferWrap.slice();
                    byteBufferWrap.limit(i6);
                    String string2 = charset.decode(byteBufferSlice).toString();
                    if (!string2.equals("__NULL__")) {
                        return string2;
                    }
                } else {
                    if (iB != 1) {
                        if (iB == 2) {
                            return Integer.valueOf(byteBufferWrap.getInt());
                        }
                        if (iB == 3) {
                            return Long.valueOf(byteBufferWrap.getLong());
                        }
                        if (iB == 4) {
                            return Float.valueOf(byteBufferWrap.getFloat());
                        }
                        if (iB == 5) {
                            return Boolean.valueOf(byteBufferWrap.get() != 0);
                        }
                        switch (i5) {
                            case 1:
                                str2 = "STRING";
                                break;
                            case 2:
                                str2 = "STRING_SET";
                                break;
                            case 3:
                                str2 = "INT";
                                break;
                            case 4:
                                str2 = "LONG";
                                break;
                            case 5:
                                str2 = "FLOAT";
                                break;
                            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                                str2 = "BOOLEAN";
                                break;
                            default:
                                str2 = "null";
                                break;
                        }
                        throw new SecurityException("Unhandled type for encrypted pref value: ".concat(str2));
                    }
                    n.c cVar = new n.c(0);
                    while (byteBufferWrap.hasRemaining()) {
                        int i7 = byteBufferWrap.getInt();
                        ByteBuffer byteBufferSlice2 = byteBufferWrap.slice();
                        byteBufferSlice2.limit(i7);
                        byteBufferWrap.position(byteBufferWrap.position() + i7);
                        cVar.add(StandardCharsets.UTF_8.decode(byteBufferSlice2).toString());
                    }
                    if (cVar.f5832c != 1 || !"__NULL__".equals(cVar.f5831b[0])) {
                        return cVar;
                    }
                }
            }
            return null;
        } catch (GeneralSecurityException e) {
            throw new SecurityException("Could not decrypt value. " + e.getMessage(), e);
        }
    }

    @Override // android.content.SharedPreferences
    public final boolean contains(String str) {
        if (c(str)) {
            throw new SecurityException(S.f(str, " is a reserved key for the encryption keyset."));
        }
        return this.f2547a.contains(a(str));
    }

    @Override // android.content.SharedPreferences
    public final SharedPreferences.Editor edit() {
        return new a(this, this.f2547a.edit());
    }

    @Override // android.content.SharedPreferences
    public final Map getAll() {
        HashMap map = new HashMap();
        for (Map.Entry<String, ?> entry : this.f2547a.getAll().entrySet()) {
            if (!c(entry.getKey())) {
                try {
                    String str = new String(this.e.b(AbstractC0366f.a(entry.getKey()), this.f2549c.getBytes()), StandardCharsets.UTF_8);
                    if (str.equals("__NULL__")) {
                        str = null;
                    }
                    map.put(str, b(str));
                } catch (GeneralSecurityException e) {
                    throw new SecurityException("Could not decrypt key. " + e.getMessage(), e);
                }
            }
        }
        return map;
    }

    @Override // android.content.SharedPreferences
    public final boolean getBoolean(String str, boolean z4) {
        Object objB = b(str);
        return objB instanceof Boolean ? ((Boolean) objB).booleanValue() : z4;
    }

    @Override // android.content.SharedPreferences
    public final float getFloat(String str, float f4) {
        Object objB = b(str);
        return objB instanceof Float ? ((Float) objB).floatValue() : f4;
    }

    @Override // android.content.SharedPreferences
    public final int getInt(String str, int i4) {
        Object objB = b(str);
        return objB instanceof Integer ? ((Integer) objB).intValue() : i4;
    }

    @Override // android.content.SharedPreferences
    public final long getLong(String str, long j4) {
        Object objB = b(str);
        return objB instanceof Long ? ((Long) objB).longValue() : j4;
    }

    @Override // android.content.SharedPreferences
    public final String getString(String str, String str2) {
        Object objB = b(str);
        return objB instanceof String ? (String) objB : str2;
    }

    @Override // android.content.SharedPreferences
    public final Set getStringSet(String str, Set set) {
        Object objB = b(str);
        Set cVar = objB instanceof Set ? (Set) objB : new n.c(0);
        return cVar.size() > 0 ? cVar : set;
    }

    @Override // android.content.SharedPreferences
    public final void registerOnSharedPreferenceChangeListener(SharedPreferences.OnSharedPreferenceChangeListener onSharedPreferenceChangeListener) {
        this.f2548b.add(onSharedPreferenceChangeListener);
    }

    @Override // android.content.SharedPreferences
    public final void unregisterOnSharedPreferenceChangeListener(SharedPreferences.OnSharedPreferenceChangeListener onSharedPreferenceChangeListener) {
        this.f2548b.remove(onSharedPreferenceChangeListener);
    }
}
