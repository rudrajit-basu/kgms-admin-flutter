package com.kgmskid.kgms_admin

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

import com.google.firebase.ktx.Firebase
import com.google.firebase.ktx.initialize
import com.google.firebase.storage.ktx.storage
import org.json.JSONArray
import org.json.JSONException
import com.google.firebase.storage.StorageMetadata
import org.json.JSONObject
import android.content.Intent
import com.google.android.youtube.player.YouTubeStandalonePlayer

class MainActivity: FlutterActivity() {
	private val CHANNEL = "flutter.kgmskid.kgms_admin/firestorage"
	private val storage = Firebase.storage
	private val ytApiKey = "AIzaSyDOEOPl4c9-au6ZbRcoGTtkr3tmI9dwG9U"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
	      call, result ->
	      if(call.method == "getMediaStorage"){
	      	println("getMediaStorage method called !")
	      	val subDir = call.arguments as String
			val listRef = storage.reference.child("kgms-images").child(subDir)
			val jsonArr = JSONArray()
	      	listRef.listAll()
	      		.addOnSuccessListener { listResult ->
	      			listResult.items.forEach { item ->
	      			
		      			try{
	      					jsonArr.put(item.getName())
	      				} catch (e: JSONException){
	      					 println(e)
	      					 result.error("Kotlin Side", "JSON create", null)
	      				}

	      			}
	      			result.success(jsonArr.toString())
	      		}
	      		.addOnFailureListener {
	      			result.error("Kotlin Side", "FireStorage", null)
	      		}
	      }

	      if(call.method == "playYoutubeVideo"){
	      	//println("playYoutubeVideo method called !")
	      	val videoId = call.arguments as String
	      	//println("videoId from kt --> $videoId")
	      	val intent = YouTubeStandalonePlayer.createVideoIntent(this, ytApiKey, videoId, 0, false, true)
	      	startActivity(intent)
	      	result.success(true)
	      }

	      if(call.method == "getUserAgent"){
	      	result.success(System.getProperty("http.agent"))
	      }
	    }
    }
}
